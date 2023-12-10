package compiler.cs.compilation.selection;

import compiler.cs.tools.Logger;
import compiler.cs.compilation.preprocessing.CompilerParameters;
import haxe.io.Path;
import compiler.cs.system.System;

class CompilerSearch {
	var params: CompilerParameters;
	var system:System;
	var logger:Logger;

	var path:String = null;
	var compiler:String = null;

	//params:
	var version:Null<Int>;
	var csharpCompiler:String;
	var silverlight:Bool;

	public function new(params: CompilerParameters, system:System, logger:Logger) {
		this.params = params;
		this.system = system;
		this.logger = logger;

		this.version = params.version;
		this.csharpCompiler = params.csharpCompiler;
		this.silverlight = params.silverlight;
	}


	function log(text: String, ?pos:haxe.PosInfos) {
		this.logger.log(text, pos);
	}


	public function search(): CompilerInfo
	{
		if (params.csharpCompiler == null) {
			log('finding compiler...');
			//if windows look first for MSVC toolchain
			if (system.systemName() == "Windows")
				findMsvc();

			if (path == null)
			{
				this.findMonoCompiler();
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

		return {
			path: path,
			compiler: compiler,
			command: genCommand(path, compiler)
		};
	}

	function genCommand(path:String, compiler:String) {
		var extension = "";
		if(system.systemName() == "Windows"){
			extension = (this.compiler == "csc" ? ".exe" : ".bat");
		}

		var compilerExec = this.compiler + extension;
		var command      = Path.join([this.path, compilerExec]);

		return command;
	}

	function findMonoCompiler() {
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

		for (winsubdir in ["\\Microsoft.NET\\Framework64", "\\Microsoft.NET\\Framework"])
		{
			var foundPath = searchMsvcIn(Path.join([windir, winsubdir]));
			if (foundPath != null)
			{
				this.path = foundPath;
				this.compiler = "csc";
				return;
			}
		}
	}

	function searchMsvcIn(path:String) {
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

					//Try to get greater version of compiler
					if (!Math.isNaN(ver) && (foundVer == null || foundVer < ver))
					{
						var compilerPath = Path.join([path, f, 'csc.exe']);

						if (system.exists(compilerPath))
						{
							log('found path:$compilerPath');
							foundPath = Path.directory(compilerPath);
							foundVer = ver;
						}
					}
				}
			}
		}

		return foundPath;
	}
}