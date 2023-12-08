package compiler.cs;
import haxe.io.Path;
import compiler.Compiler;
import compiler.Error;

import compiler.cs.system.System;
import compiler.cs.system.StdSystem;

import haxe.io.BytesOutput;
import input.Data;
using StringTools;


class CSharpCompiler extends Compiler
{
	private var path:String;
	private var compiler:String;
	private var delim:String;

	public var version(default, null):Null<Int>;
	public var silverlight(default, null):Bool;
	public var unsafe(default, null):Bool;
	public var verbose(default, null):Bool;
	public var warn(default, null):Bool;
	public var debug(default, null):Bool;
	public var dll(default, null):Bool;
	public var name(default, null):String;
	public var libs(default, null):Array<{ name:String, hint:String }>;
	public var csharpCompiler(default, null):Null<String>;
	public var arch(default,null):Null<String>;

	public var data(default, null):Data;

	var cmd:CommandLine;
	var system:System;

	public function new(cmd:CommandLine, ?system:System)
	{
		this.cmd = cmd;
		this.system = if(system != null) system else new StdSystem();
	}

	private function log(str:String,?pos:haxe.PosInfos)
	{
		if (this.verbose) haxe.Log.trace(str,pos);
	}

	override public function compile(data:Data):Void
	{
		this.data = data;
		preProcess();
		if (!system.exists("bin"))
			system.createDirectory("bin");
		findCompiler();
		writeProject();
		doCompilation();
	}

	@:access(haxe.io.Path.escape)
	function generateArgs() {
		var output = cmd.output == null ? 'bin/' + this.name : Tools.addPath(data.baseDir, cmd.output),
			outDir = haxe.io.Path.directory(output);
		var args = ['/nologo',
					'/optimize' + (debug ? '-' : '+'),
					'/debug' + (debug ? '+' : '-'),
					'/unsafe' + (unsafe ? '+' : '-'),
					'/warn:' + (warn ? '1' : '0'),
					'/out:' + output + "." + (dll ? "dll" : "exe"),
					'/target:' + (dll ? "library" : "exe") ];
		if(this.arch != null)
			args.push('/platform:${this.arch}');
		log('preparing cmd arguments:  ${args.join(" ")}');
		if (data.main != null && !dll) {
			var idx = data.main.lastIndexOf(".");
			var namespace = data.main.substring(0, idx + 1);
			var main = data.main.substring(idx + 1);
			args.push('/main:' + namespace + (main == "Main" ? "EntryPoint__Main" : main));
		}
		for (ref in libs)
		{
			if (ref.hint != null)
			{
				var fullpath = Tools.addPath(data.baseDir,ref.hint),
				    mypath = Tools.addPath(outDir, haxe.io.Path.withoutDirectory(ref.hint));
				Tools.copyIfNewer(fullpath, mypath);

				args.push('/reference:$mypath');
			}
		}
		for (res in data.resources) {
			res = haxe.io.Path.escape(res, true);
			// res = haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(res));
			args.push('/res:src' + delim + 'Resources' + delim + res + ",src.Resources." + res);
		}
		for (file in data.modules)
			args.push("src" + delim + file.path.split(".").join(delim) + ".cs");

		for (opt in data.opts)
			args.push(opt);

		return args;
	}
	
	function doCompilation() {
		var args = generateArgs();

		log('cmd arguments:  ${args.join(" ")}');
		var ret = 0;
		try
		{
			if (system.systemName() == "Windows" && !data.defines.exists("LONG_COMMAND_LINE"))
			{
				//save in a file
				system.saveContent('cmd',args.join('\n'));
				args = ['@cmd'];
			}

			var extension = "";
			if(system.systemName() == "Windows"){
				extension = (this.compiler == "csc" ? ".exe" : ".bat");
			}
			var command = this.path + this.compiler + extension;
			
			if (verbose)
				system.println(command + " " + args.join(" "));

			ret = system.command(command, args);
		}
		catch (e:Dynamic)
		{
			throw Error.CompilerNotFound;
		}

		if (ret != 0)
			throw Error.BuildFailed;
	}

	private function writeProject()
	{
		log('writing csproj');
		var bytes = new BytesOutput();
		new CsProjWriter(bytes).write(this);

		var projectPath = this.name + ".csproj";
		var bytes = bytes.getBytes();
		if (system.exists(projectPath))
		{
			if (system.getBytes(projectPath).compare(bytes) == 0)
				return;
		}

		system.saveBytes(projectPath, bytes);
	}

	private function findCompiler()
	{
		if (csharpCompiler == null) {
		  log('finding compiler...');
		  //if windows look first for MSVC toolchain
		  if (system.systemName() == "Windows")
		  	findMsvc();

		  if (path == null)
		  {
			//look for a suitable mono compiler, see http://www.mono-project.com/docs/about-mono/languages/csharp/
			var compiler:String = null;
			if (version == null)
			{
				// if no version was specified try to find the newest compiler
				if (exists("mcs")) compiler = "mcs";
				else if (exists("dmcs")) compiler = "dmcs";
				else if (silverlight && exists("smcs")) compiler = "smcs";
				else if (exists("gmcs")) compiler = "gmcs";
			}
			else
			{
				// if a version was specified try to find the best matching
				if (version <= 20 && exists("gmcs")) compiler = "gmcs";
				else if (version <= 21 && silverlight && exists("smcs")) compiler = "smcs";
				else if (exists("mcs")) compiler = "mcs";
				else if (version <= 40 && exists("dmcs")) compiler = "dmcs";
			}
			if (compiler != null)
			{
				this.path = "";
				this.compiler = compiler;
				log('Found mono compiler: $compiler for version: $version');
			}
		  }
		} else {
		  if (exists(this.csharpCompiler))
			{
				this.path = "";
				this.compiler = this.csharpCompiler;
			}
		}

		log('Compiler path: $path ; Compiler: $compiler');
		if (path == null)
		{
			//TODO look for mono path
		 	throw Error.CompilerNotFound;
		}
	}

	private function exists(exe:String, checkArgs:Array<String> = null):Bool
	{
		if (checkArgs == null) checkArgs = ["-help"];

		return if (system.systemName() == "Windows")
			_exists(exe + ".exe", checkArgs) || _exists(exe + ".bat", checkArgs);
		else
			_exists(exe, checkArgs);
	}

	private function _exists(exe:String, checkArgs:Array<String>):Bool
	{
		try
		{
			var ret = system.startProcess(exe, checkArgs);
			ret.stdout.readAll();
			return ret.exitCode() == 0;
		}
		catch (e:Dynamic)
		{
			return false;
		}
	}

	private function findMsvc()
	{
		log('looking for MSVC directory');
		//se if it is in path
		if (exists("csc"))
		{
			this.path = "";
			this.compiler = "csc";
			log('found csc compiler');
		}

		var windir = system.getEnv("windir");
		if (windir == null)
			windir = "C:\\Windows";
		log('WINDIR: ${windir} (${system.getEnv('windir')})');

		for (path in [windir+"\\Microsoft.NET\\Framework64", windir+"\\Microsoft.NET\\Framework"])
		{
			log('looking up framework at ' + path);

			var foundVer:Null<Float> = null;
			var foundPath = null;
			if (system.exists(path))
			{
				var regex = ~/v(\d+.\d+)/;
				for (f in system.readDirectory(path))
				{
					if (regex.match(f))
					{
						var ver = Std.parseFloat(regex.matched(1));
						log('found framework: $f (ver $ver)');
						if (!Math.isNaN(ver) && (foundVer == null || foundVer < ver))
						{
							if (system.exists((path + "/" + f + "/csc.exe")))
							{
								log('found path:$path/$f/csc.exe');
								foundPath = path + '/' + f;
								foundVer = ver;
							}
						}
					}
				}
			}
			if (foundPath != null)
			{
				this.path = foundPath + "/";
				this.compiler = "csc";
			}
		}

	}

	private function preProcess()
	{
		delim = system.systemName() == "Windows" ? "\\" : "/";

		//get requested version
		var version:Null<Int> = null;
		for (ver in [50,45,40,35,30,21,20])
		{
			if (data.defines.exists("NET_" + ver))
			{
				version = ver;
				break;
			}
		}
		this.version = version;

		// get requested csharp compiler
		this.csharpCompiler = data.definesData.get("csharp-compiler");

		//get important defined vars
		this.silverlight = data.defines.exists("silverlight");
		this.dll = data.defines.exists("dll") || data.main == null;
		this.debug = data.defines.exists("debug");
		this.unsafe = data.defines.exists("unsafe");
		this.warn = data.defines.exists("warn");
		this.verbose = data.defines.exists("verbose");
		this.arch = data.definesData.get('arch');

		// massage the library names
		this.libs = [];
		for (lib in data.libs)
		{
			var parsed = {name: lib, hint: null};
			if (lib.lastIndexOf(".dll") > 0)
			{
				parsed.hint = lib;
				parsed.name = lib.split(delim).pop();
				parsed.name = parsed.name.substring(0, parsed.name.lastIndexOf(".dll"));
			}

			this.libs.push(parsed);
		}


		// get name from main class if there's one
		// or from output directory name if there's none
		var name = null;
		if (data.main != null)
		{
			name = data.main.split('.').pop();
		}
		else
		{
			name = Path.withoutDirectory(this.system.getCwd());
		}
		if (debug)
			name += "-Debug";
		this.name = name;
	}

}
