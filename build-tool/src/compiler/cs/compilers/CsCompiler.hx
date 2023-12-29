package compiler.cs.compilers;

import compiler.cs.compilation.preprocessing.CompilerParameters;

interface CsCompiler {
	public var compiler(default, null):String;

	public function findCompiler(params:CompilerParameters): Bool;
}