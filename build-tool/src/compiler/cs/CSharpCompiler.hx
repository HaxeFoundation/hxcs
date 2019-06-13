package compiler.cs;
import compiler.Compiler;
import compiler.Error;
import haxe.io.BytesOutput;
import input.Data;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
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
	public var warn(default, null):Int;
	public var debug(default, null):Bool;
	public var dll(default, null):Bool;
	public var name(default, null):String;
	public var libs(default, null):Array<{ name:String, hint:String }>;
	public var csharpCompiler(default, null):Null<String>;
	public var arch(default,null):Null<String>;

	public var data(default, null):Data;

	var cmd:CommandLine;

	public function new(cmd:CommandLine)
	{
		this.cmd = cmd;
	}

	private function log(str:String,?pos:haxe.PosInfos)
	{
		if (this.verbose) haxe.Log.trace(str,pos);
	}

	@:access(haxe.io.Path.escape)
	override public function compile(data:Data):Void
	{
		this.data = data;
		preProcess();
		if (!FileSystem.exists("bin"))
			FileSystem.createDirectory("bin");
		findCompiler();
		writeProject();

		var output = cmd.output == null ? 'bin/' + this.name : Tools.addPath(data.baseDir, cmd.output),
				outDir = haxe.io.Path.directory(output);
		var args = ['/nologo',
					'/optimize' + (debug ? '-' : '+'),
					'/debug' + (debug ? '+' : '-'),
					'/unsafe' + (unsafe ? '+' : '-'),
					'/warn:' + Std.string(warn),
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

		log('cmd arguments:  ${args.join(" ")}');
		var ret = 0;
		try
		{
			if (Sys.systemName() == "Windows" && !hasDefine(data, LONG_COMMAND_LINE))
			{
				//save in a file
				sys.io.File.saveContent('cmd',args.join('\n'));
				args = ['@cmd'];
			}
			if (verbose)
				Sys.println(this.path + this.compiler + " " + args.join(" "));
			ret = Sys.command(this.path + this.compiler + (Sys.systemName() == "Windows" ? (this.compiler == "csc" ? ".exe" : ".bat") : ""), args);
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

		var bytes = bytes.getBytes();
		if (FileSystem.exists(this.name + ".csproj"))
		{
			if (File.getBytes(this.name + ".csproj").compare(bytes) == 0)
				return;
		}

		File.saveBytes(this.name + ".csproj", bytes);
	}

	private function findCompiler()
	{
		if (csharpCompiler == null) {
			log('finding compiler...');
			//if windows look first for MSVC toolchain
			if (Sys.systemName() == "Windows")
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
					else if (version <= 40 && exists("dmcs")) compiler = "dmcs";
					else if (exists("mcs")) compiler = "mcs";
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

		return if (Sys.systemName() == "Windows")
			_exists(exe + ".exe", checkArgs) || _exists(exe + ".bat", checkArgs);
		else
			_exists(exe, checkArgs);
	}

	private function _exists(exe:String, checkArgs:Array<String>):Bool
	{
		try
		{
			var ret = new Process(exe, checkArgs);
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

		var windir = Sys.getEnv("windir");
		if (windir == null)
			windir = "C:\\Windows";
		log('WINDIR: ${windir} (${Sys.getEnv('windir')})');
		var path = null;

		for (path in [windir+"\\Microsoft.NET\\Framework64", windir+"\\Microsoft.NET\\Framework"])
		{
			log('looking up framework at ' + path);

			var foundVer:Null<Float> = null;
			var foundPath = null;
			if (FileSystem.exists(path))
			{
				var regex = ~/v(\d+.\d+)/;
				for (f in FileSystem.readDirectory(path))
				{
					if (regex.match(f))
					{
						var ver = Std.parseFloat(regex.matched(1));
						log('found framework: $f (ver $ver)');
						if (!Math.isNaN(ver) && (foundVer == null || foundVer < ver))
						{
							if (FileSystem.exists((path + "/" + f + "/csc.exe")))
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
		delim = Sys.systemName() == "Windows" ? "\\" : "/";

		//get requested version
		var version:Null<Int> = null;
		for (ver in [45,40,35,30,21,20])
		{
			if (data.defines.exists("NET_" + ver))
			{
				version = ver;
				break;
			}
		}
		this.version = version;

		// get requested csharp compiler
		this.csharpCompiler = getDefine(data, CSHARP_COMPILER);

		//get important defined vars
		this.silverlight = hasDefine(data, SILVERLIGHT);
		this.dll = hasDefine(data, DLL) || data.main == null;
		this.warn = getWarningLevel(data);
		this.arch = getDefine(data, ARCH);
		this.unsafe = data.defines.exists("unsafe");
		this.debug = data.defines.exists("debug");
		this.verbose = data.defines.exists("verbose");

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
		var name = if (data.main != null)
		{
			var idx = data.main.lastIndexOf(".");
			if (idx != -1)
				data.main.substr(idx + 1);
			else
				data.main;
		}
		else
		{
			var name = Sys.getCwd();
			name = name.substr(0, name.length - 1);
			if (name.lastIndexOf("\\") > name.lastIndexOf("/"))
				name = name.split("\\").pop();
			else
				name = name.split("/").pop();
		}
		if (debug)
			name += "-Debug";

		this.name = name;
	}

	private function getWarningLevel(data:Data):Int
	{
		if (!hasDefine(data, WARN)) return 0;
		var warnDefine = getDefine(data, WARN);
		if (warnDefine == "") return 1;
		return Std.parseInt(warnDefine);
	}

	private function hasDefine(data:Data, def:CsCustomDefine):Bool
	{
		return data.defines.exists(def.withNamespace()) || data.defines.exists(def);
	}

	private function getDefine(data:Data, def:CsCustomDefine):String
	{
		var d = data.definesData.get(def.withNamespace());
		if (d != null) return d;
		return data.definesData.get(def);
	}
}
