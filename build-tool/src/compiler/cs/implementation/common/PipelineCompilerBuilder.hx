package compiler.cs.implementation.common;

import haxe.Rest;
import compiler.cs.compilation.CompilerParameters;
import compiler.cs.compilation.CsCompiler;
import compiler.cs.compilation.pipeline.ProjectWriter;
import compiler.cs.compilation.pipeline.CsBuilder;
import compiler.cs.compilation.pipeline.EnvironmentConfigurator;
import compiler.cs.compilation.pipeline.ArgumentsGenerator;
import compiler.cs.compilation.pipeline.CompilerFinder;
import compiler.cs.compilation.pipeline.CompilerPipeline;
import compiler.cs.implementation.common.CsProjectGenerator;
import compiler.cs.implementation.common.DefaultCsBuilder;

import compiler.cs.system.System;
import compiler.cs.tools.Logger;


typedef PipelineCompilerBuilder  = BasePipelineCompilerBuilder<PipelineCompilerBuilder>;

class BasePipelineCompilerBuilder<Self:BasePipelineCompilerBuilder<Self>> {
	var sys:System;
	var log:Null<Logger>;

	var argsGenerator(default, null):ArgumentsGenerator;
	var composedConfig:ComposedConfigurator;
	var _csBuilder(default, null):CsBuilder;
	var projWriter(default, null):ProjectWriter;
	var compilerFinder(default, null):CompilerFinder;
	var _afterBuild:ComposedCallback<CompilerParameters>;

	public function new(system:System, ?logger:Logger) {
		this.sys = system;
		this.log = logger;

		this._csBuilder = new DefaultCsBuilder(sys, log);
		this.projWriter = new CsProjectGenerator(sys, log);
		this.composedConfig = new ComposedConfigurator();
		this._afterBuild = new ComposedCallback();
	}

	public static function builder(system:System, ?logger:Logger) {
		return new PipelineCompilerBuilder(system, logger);
	}

	public function system(system:System) {
		this.sys = system;
		return self();
	}

	public function logger(logger:Null<Logger>) {
		this.log = logger;
		return self();
	}

	public function finder(compilerFinder: CompilerFinder) {
		this.compilerFinder = compilerFinder;
		return self();
	}

	public function projectWriter(projWriter: ProjectWriter) {
		this.projWriter = projWriter;
		return self();
	}

	public function argumentGenerator(argsGenerator:ArgumentsGenerator) {
		this.argsGenerator = argsGenerator;
		return self();
	}

	public function csBuilder(builder:CsBuilder) {
		this._csBuilder = builder;
		return self();
	}

	public function addConfigurator(envConfig: EnvironmentConfigurator) {
		this.composedConfig.addConfigurator(envConfig);
		return self();
	}

	public function afterBuild(afterBuild: AfterBuildCallback) {
		this._afterBuild.add(afterBuild);
		return self();
	}

	inline function self(): Self {
		return cast(this);
	}

	public function build(
		?finder:CompilerFinder,
		?projectWriter:ProjectWriter,
		?argsGenerator:ArgumentsGenerator,
		?csBuilder:CsBuilder,
		configurators:Rest<EnvironmentConfigurator>
	): CsCompiler{
		this.composedConfig.addAll(configurators.toArray());

		return new CompilerPipeline(
			require('CompilerFinder', choice(finder, this.compilerFinder)),
			require('ProjectWriter', choice(projectWriter, this.projWriter)),
			require('ArgumentsGenerator', choice(argsGenerator, this.argsGenerator)),
			require('CsBuilder', choice(csBuilder, this._csBuilder)),
			composedConfig,
			_afterBuild.callback()
		);
	}

	function choice<T>(opt1:Null<T>, opt2:Null<T>): Null<T> {
		return if(opt1 != null) opt1 else opt2;
	}
	function require<T>(object:String, arg:T): T {
		if(arg == null)
			throw new MissingDependencyException('Missing $object');

		return arg;
	}
}