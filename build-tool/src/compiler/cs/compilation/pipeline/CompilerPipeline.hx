package compiler.cs.compilation.pipeline;

import compiler.cs.compilation.CompilerParameters;

typedef AfterBuildCallback = (CompilerParameters)->Void;

class CompilerPipeline implements CsCompiler{
	public var compiler(default, null):String;

	var finder:CompilerFinder;
	var projWriter:ProjectWriter;
	var argsGenerator:ArgumentsGenerator;
	var builder:CsBuilder;
	var envConfigurator:Null<EnvironmentConfigurator>;
	var afterBuild:AfterBuildCallback;

	public function new(
		finder:CompilerFinder,
		projWriter:ProjectWriter,
		argsGenerator:ArgumentsGenerator,
		builder:CsBuilder,
		?environmentConfigurator:EnvironmentConfigurator,
		?afterBuild:AfterBuildCallback)
	{
		this.finder = finder;
		this.projWriter = projWriter;
		this.argsGenerator = argsGenerator;
		this.builder = builder;
		this.envConfigurator = environmentConfigurator;
		this.afterBuild = afterBuild;
	}

	public function findCompiler(params:CompilerParameters):Bool {
		this.compiler = finder.findCompiler(params);

		return this.compiler != null;
	}


	public function compile(params:CompilerParameters) {
		ensureCompiler(params);

		if(envConfigurator != null){
			params = envConfigurator.configure(params);
		}

		projWriter.writeProject(params);
		
		var args = argsGenerator.generateArgs(params);

		this.builder.build(this.compiler, args, params);

		if(afterBuild != null){
			afterBuild(params);
		}
	}

	function ensureCompiler(params:CompilerParameters) {
		if(compiler == null){
			findCompiler(params);
		}
		checkHasCompiler();
	}

	function checkHasCompiler() {
		if(compiler == null){
			throw Error.CompilerNotFound;
		}
	}
}