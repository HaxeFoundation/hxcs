package compiler.cs.compilation.selection;

import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.tools.Logger;
import compiler.cs.system.System;

class CompilerSelector {
	var system:System;
	var logger:Logger;

	public function new(system:System, logger:Logger) {
		this.system = system;
		this.logger = logger;
	}

	public function findCompiler(params: CompilerParameters){
		var search = new CompilerSearch(params, system, logger);

		return search.search();
	}
}