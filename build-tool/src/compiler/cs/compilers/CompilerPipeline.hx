package compiler.cs.compilers;

import compiler.cs.compilation.CsBuilder;
import compiler.cs.compilation.ArgumentsGenerator;
import compiler.cs.compilation.ProjectWriter;
import compiler.cs.compilation.CompilerFinder;
import compiler.cs.compilation.preprocessing.CompilerParameters;

class CompilerPipeline implements CsCompiler{
	public var compiler(default, null):String;

	var finder:CompilerFinder;
	var projWriter:ProjectWriter;
	var argsGenerator:ArgumentsGenerator;
	var builder:CsBuilder;

	public function new(
		finder:CompilerFinder, projWriter:ProjectWriter, argsGenerator:ArgumentsGenerator,
		builder:CsBuilder)
	{
		this.finder = finder;
		this.projWriter = projWriter;
		this.argsGenerator = argsGenerator;
		this.builder = builder;
	}

	public function findCompiler(params:CompilerParameters):Bool {
		this.compiler = finder.findCompiler(params);

		return this.compiler != null;
	}


	public function compile(params:CompilerParameters) {
		if(compiler == null){
			findCompiler(params);
		}
		checkHasCompiler();

		projWriter.writeProject(params);
		
		var args = argsGenerator.generateArgs(params);

		this.builder.build(this.compiler, args, params);
	}

	function checkHasCompiler() {
		if(compiler == null){
			throw Error.CompilerNotFound;
		}
	}
}