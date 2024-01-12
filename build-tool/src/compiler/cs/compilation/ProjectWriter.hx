package compiler.cs.compilation;

import compiler.cs.compilation.preprocessing.CompilerParameters;

interface ProjectWriter {
	public function writeProject(params:CompilerParameters):Void;
}