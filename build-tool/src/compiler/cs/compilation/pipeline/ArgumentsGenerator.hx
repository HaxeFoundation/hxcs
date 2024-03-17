package compiler.cs.compilation.pipeline;

import compiler.cs.compilation.CompilerParameters;

interface ArgumentsGenerator {
	public function generateArgs(params: CompilerParameters):Array<String>;
}