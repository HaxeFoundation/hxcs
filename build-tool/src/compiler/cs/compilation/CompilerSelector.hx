package compiler.cs.compilation;

import compiler.cs.compilation.CompilerParameters;


class CompilerSelector {
	public function new() {
	}

	public function
		selectFrom(compilers:Iterable<CsCompiler>, params:CompilerParameters): CsCompiler
	{
		for(comp in compilers){
			if(comp.findCompiler(params))
				return comp;
		}

		return null;
	}

	public function requireCompiler(compilers:Iterable<CsCompiler>, params:CompilerParameters) {
		var comp = selectFrom(compilers, params);

		if(comp == null)
			throw Error.CompilerNotFound;

		return comp;
	}
}