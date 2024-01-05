package hxcs.fakes;

import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.compilers.CsCompiler;

@:structInit
class FakeCsCompiler implements CsCompiler{
	public var compiler(default, default):String;

	public var found(default, default):Bool;

	/**
		Syntax sugar to make compiler from parameters.
		Example:
			FakeCsCompiler.make({
				compiler: "mycompiler",
				found: true
			})
	**/
	public static function make(comp:FakeCsCompiler) {
		return comp;
	}

	public function new(?compiler:String, ?found:Bool) {
		this.compiler = compiler;
		this.found = (found == true);
	}

	// interface ---------------------------------

	public function findCompiler(params:CompilerParameters):Bool {
		return found;
	}
}