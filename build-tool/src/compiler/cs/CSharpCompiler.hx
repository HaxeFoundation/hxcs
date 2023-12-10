package compiler.cs;

import compiler.cs.compilation.building.DefaultCompilerRunner;
import compiler.cs.compilation.building.CompilerRunner;
import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.compilation.project.ProjectGenerator;
import compiler.cs.compilation.selection.CompilerSelector;
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
	var selector	 :CompilerSelector;
	var projGenerator:ProjectGenerator;

	var params :CompilerParameters;
	var builder:CompilerRunner;

	public function new(cmd:CommandLine, ?system:System, ?logger:Logger)
	{
		this.cmd = cmd;
		this.system = if(system != null) system else new StdSystem();
		this.logger = if(logger != null) logger else new Logger();

		this.selector      = new CompilerSelector(this.system, this.logger);
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
		var compileInfo = this.selector.findCompiler(params);

        this.builder = new DefaultCompilerRunner(compileInfo, params, system, logger);
	}

	function writeProject(){
		this.projGenerator.writeProject(params);
	}
	
	function doCompilation() {
		builder.compile(params);
	}
}
