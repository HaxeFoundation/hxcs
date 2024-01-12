package compiler.cs.compilation.finders;

import compiler.cs.compilation.preprocessing.CompilerParameters;

using compiler.cs.compilers.CompilerTools;


class CustomCompilerFinder extends BaseCompilerFinder{
	public override function findCompiler(params:CompilerParameters):Null<String> {
		if(params.csharpCompiler == null)
			return null;

		return system.checkCompiler(params.csharpCompiler);
	}
}