package compiler.cs.compilers;

import haxe.io.Path;
import haxe.Constraints.IMap;
import compiler.cs.system.System;

class CompilerTools {

	public static function compilerExists(system:System, exe:String, checkArgs:Array<String> = null):Bool
	{
		return checkCompiler(system, exe, checkArgs) != null;
	}


	public static function
		checkCompiler(system:System, compiler:String, checkArgs:Array<String> = null):String
	{
		if (checkArgs == null) checkArgs = ["-help"];

		var extensions = (system.systemName() == "Windows")
							? ["exe", "bat"] : [null];

		for (ext in extensions){
			var cmd = withExtension(compiler, ext);
			if(_exists(system, cmd, checkArgs)){
				return cmd;
			}
		}

		return null;
	}

	static function withExtension(path:String, ?ext:String) {
		if(ext == null)
			return path;
		return Path.withExtension(path, ext);
	}

	static function _exists(system:System, exe:String, checkArgs:Array<String>):Bool
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

	public static function withSystemExtension(
		system:System, path:String, extensionMap:IMap<String, String>)
	{
		var ext = extensionMap.get(system.systemName());

		return if(ext == null) path else Path.withExtension(path, ext);
	}
}