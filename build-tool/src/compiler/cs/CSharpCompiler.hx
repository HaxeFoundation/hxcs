package compiler.cs;

import compiler.cs.compilers.CustomCompiler;
import compiler.cs.compilers.MonoCompiler;
import compiler.cs.compilers.MsvcCompiler;
import compiler.cs.compilers.CsCompiler;
import compiler.cs.compilation.CompilerSelector;
import compiler.cs.compilation.building.DefaultCompilerRunner;
import compiler.cs.compilation.building.CompilerRunner;
import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.compilation.project.ProjectGenerator;
import compiler.cs.compilation.preprocessing.ParametersParser;
import compiler.cs.tools.Logger;
import compiler.Compiler;

import compiler.cs.system.System;
import compiler.cs.system.StdSystem;

import input.Data;

using StringTools;
using compiler.cs.system.SystemTools;


class CSharpCompiler extends Compiler
{
	var cmd:CommandLine;
	var system:System;
	var logger:Logger;

	var paramParser  :ParametersParser;

	var compilers    :Array<CsCompiler>;
	var csSelector	 :CompilerSelector;
	var projGenerator:ProjectGenerator;

	var params :CompilerParameters;
	var builder:CompilerRunner;

	public function new(cmd:CommandLine, ?system:System, ?logger:Logger)
	{
		this.cmd = cmd;
		this.system = if(system != null) system else new StdSystem();
		this.logger = if(logger != null) logger else new Logger();

		this.compilers = [
			new CustomCompiler(this.system, this.logger),
			new MsvcCompiler(this.system, this.logger),
			new MonoCompiler(this.system, this.logger)
		];

		this.csSelector	   = new CompilerSelector();	
		this.paramParser   = new ParametersParser(this.system);
		this.projGenerator = new ProjectGenerator(this.system, this.logger);
	}

	override public function compile(data:Data):Void
	{
		preProcess(data);
		createBuildDirectory();
		findCompiler();
		writeProject();
		doCompilation();
	}

	function preProcess(data:Data) {
		params = paramParser.parse(data, cmd.output);
		logger.verbose = params.verbose;

		return params;
	}

	function createBuildDirectory() {
		// Maybe should create params.outDir (by default is bin, but may be different)
		if (!system.exists("bin"))
			system.createDirectory("bin");
	}

	function findCompiler(){
		var compiler = this.csSelector.selectFrom(compilers, params);

		this.builder = new DefaultCompilerRunner(
			compiler.compiler, params, system, logger);
	}

	function writeProject(){
		this.projGenerator.writeProject(params);
	}
	
	function doCompilation() {
		builder.compile(params);
	}
}
