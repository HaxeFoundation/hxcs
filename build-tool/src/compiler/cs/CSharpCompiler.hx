package compiler.cs;
import compiler.Compiler;
import compiler.Error;
import haxe.io.BytesOutput;
import input.Data;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

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

	public var data(default, null):Data;

	var cmd:CommandLine;

	public function new(cmd:CommandLine)
	{
		this.cmd = cmd;
	}

	override public function compile(data:Data):Void
	{
		this.data = data;
		preProcess();
		if (!FileSystem.exists("bin"))
			FileSystem.createDirectory("bin");
		findCompiler();
		writeProject();


		var args = ['/nologo',
					'/optimize' + (debug ? '-' : '+'),
					'/debug' + (debug ? '+' : '-'),
					'/unsafe' + (unsafe ? '+' : '-'),
					'/warn:' + (warn ? '1' : '0'),
					'/out:bin/' + this.name + "." + (dll ? "dll" : "exe"),
					'/target:' + (dll ? "library" : "exe") ];
		if (data.main != null && !dll) {
			var idx = data.main.lastIndexOf(".");
			var namespace = data.main.substring(0, idx + 1);
			var main = data.main.substring(idx + 1);
			args.push('/main:' + namespace + (main == "Main" ? "EntryPoint__Main" : main));
		}
		for (ref in libs) {
			if (ref.hint != null)
				args.push('/reference:${ref.hint}');
		}
		for (res in data.resources)
			args.push('/res:src' + delim + 'Resources' + delim + res + ",src.Resources." + res);
		for (file in data.modules)
			args.push("src" + delim + file.path.split(".").join(delim) + ".cs");

		var ret = 0;
		try
		{
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
		//if windows look first for MSVC toolchain
		if (Sys.systemName() == "Windows")
			findMsvc();

		if (path == null)
		{
			//look for mono
			if (exists("mcs"))
			{
				this.path = "";
				this.compiler = "mcs";
			} else if ((version == null || version <= 20) && exists("gmcs")) {
				this.path = "";
				this.compiler = "gmcs";
			} else if ((version == null || version <= 21 && silverlight) && exists("smcs")) {
				this.path = "";
				this.compiler = "smcs";
			} else if (exists("dmcs")) {
				this.path = "";
				this.compiler = "dmcs";
			}
		}

		if (path == null)
		{
			//TODO look for mono path
			throw Error.CompilerNotFound;
		}
	}

	private function exists(exe:String):Bool
	{
		if (Sys.systemName() == "Windows")
			return _exists(exe + ".exe") || _exists(exe + ".bat");
		return _exists(exe);
	}

	private function _exists(exe:String):Bool
	{
		try
		{
			var cmd = new Process(exe, []);
			cmd.exitCode();
			return true;
		}
		catch (e:Dynamic)
		{
			return false;
		}
	}

	private function findMsvc()
	{
		//se if it is in path
		if (exists("csc"))
		{
			this.path = "";
			this.compiler = "csc";
		}

#if neko
		var is64:Bool = neko.Lib.load("std", "sys_is64", 0)();
#else
		var is64 = false;
#end
		var windir = Sys.getEnv("windir");
		if (windir == null)
			windir = "C:\\Windows";
		var path = null;

		if (is64)
		{
			path = windir + "\\Microsoft.NET\\Framework64";
		} else {
			path = windir + "\\Microsoft.NET\\Framework";
		}

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
					if (!Math.isNaN(ver) && (foundVer == null || foundVer < ver))
					{
						if (FileSystem.exists((path + "/" + f + "/csc.exe")))
						{
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

		//get important defined vars
		this.silverlight = data.defines.exists("silverlight");
		this.dll = data.defines.exists("dll");
		this.debug = data.defines.exists("debug");
		this.unsafe = data.defines.exists("unsafe");
		this.warn = data.defines.exists("warn");
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

}
