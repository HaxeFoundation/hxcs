package compiler.cs.compilation;

import compiler.cs.compilation.preprocessing.CompilerParameters;

interface ArgumentsGenerator {
	public function generateArgs(params: CompilerParameters):Array<String>;
}