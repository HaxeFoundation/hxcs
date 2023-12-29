package compiler.cs.compilers;

import compiler.cs.compilation.preprocessing.CompilerParameters;

using compiler.cs.compilers.CompilerTools;


class MonoCompiler extends BaseCsCompiler{
	public static function compilers() return ['mcs', 'dmcs', 'smcs', 'gmcs'];


	public override function findCompiler(params:CompilerParameters): Bool {
		var found = findMonoCompiler(params.silverlight, params.version);

		if(found != null){
			this.compiler = system.withSystemExtension(found, ['Windows' => 'bat']);
		}

		return compiler != null;
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