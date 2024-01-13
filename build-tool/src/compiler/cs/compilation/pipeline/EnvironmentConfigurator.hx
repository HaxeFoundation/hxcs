package compiler.cs.compilation.pipeline;

import compiler.cs.compilation.CompilerParameters;

interface EnvironmentConfigurator {
	public function configure(params:CompilerParameters):CompilerParameters;
}