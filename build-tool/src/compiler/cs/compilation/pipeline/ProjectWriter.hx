package compiler.cs.compilation.pipeline;

import compiler.cs.compilation.CompilerParameters;

interface ProjectWriter {
	public function writeProject(params:CompilerParameters):Void;
}