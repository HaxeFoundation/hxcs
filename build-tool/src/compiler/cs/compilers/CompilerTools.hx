package compiler.cs.compilers;

import haxe.io.Path;
import haxe.Constraints.IMap;
import compiler.cs.system.System;

class CompilerTools {

	public static function compilerExists(system:System, exe:String, checkArgs:Array<String> = null):Bool
	{
		if (checkArgs == null) checkArgs = ["-help"];

		if (system.systemName() == "Windows")
			return _exists(system, exe + ".exe", checkArgs)
				|| _exists(system, exe + ".bat", checkArgs);
		else
			return _exists(system, exe, checkArgs);
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