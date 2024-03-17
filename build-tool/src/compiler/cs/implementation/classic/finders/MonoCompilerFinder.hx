package compiler.cs.implementation.classic.finders;

import compiler.cs.implementation.common.BaseCompilerFinder;
import compiler.cs.compilation.CompilerParameters;

using compiler.cs.tools.CompilerTools;


class MonoCompilerFinder extends BaseCompilerFinder {
	public static function compilers() return ['mcs', 'dmcs', 'smcs', 'gmcs'];

	public override function findCompiler(params:CompilerParameters):Null<String> {
		var compiler = findMonoCompiler(params.silverlight, params.version);

		if(compiler != null){
			compiler = system.withSystemExtension(compiler, ['Windows' => 'bat']);
		}

		return compiler;
	}

	function findMonoCompiler(?silverlight:Bool, ?version:Int) {
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
			// this.path = "";
			// this.compiler = compiler;
			log('Found mono compiler: $compiler for version: $version');
		}

		return compiler;
	}
}