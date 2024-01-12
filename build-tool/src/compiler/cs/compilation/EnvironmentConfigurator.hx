package compiler.cs.compilation;

import compiler.cs.compilation.preprocessing.CompilerParameters;

interface EnvironmentConfigurator {
	public function configure(params:CompilerParameters):CompilerParameters;
}