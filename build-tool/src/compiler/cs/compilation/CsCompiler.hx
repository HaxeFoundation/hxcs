package compiler.cs.compilation;

import compiler.cs.compilation.CompilerParameters;

interface CsCompiler {
	public var compiler(default, null):String;

	public function findCompiler(params:CompilerParameters): Bool;

	public function compile(params:CompilerParameters):Void;
}