package compiler.cs.compilers;

import compiler.cs.compilation.preprocessing.CompilerParameters;

using compiler.cs.compilers.CompilerTools;


class CustomCompiler extends BaseCsCompiler{
	public override function findCompiler(params:CompilerParameters): Bool {
		if(params.csharpCompiler == null)
			return false;

		this.compiler = system.checkCompiler(params.csharpCompiler);

		return compiler != null;
	}
}