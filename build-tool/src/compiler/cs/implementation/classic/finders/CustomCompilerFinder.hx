package compiler.cs.implementation.classic.finders;

import compiler.cs.implementation.common.BaseCompilerFinder;
import compiler.cs.compilation.CompilerParameters;

using compiler.cs.tools.CompilerTools;


class CustomCompilerFinder extends BaseCompilerFinder{
	public override function findCompiler(params:CompilerParameters):Null<String> {
		if(params.csharpCompiler == null)
			return null;

		return system.checkCompiler(params.csharpCompiler);
	}
}