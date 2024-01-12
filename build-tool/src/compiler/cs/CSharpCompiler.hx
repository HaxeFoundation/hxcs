package compiler.cs;

import compiler.cs.compilers.CompilersBuilder;
import compiler.cs.compilers.CsCompiler;
import compiler.cs.compilation.CompilerSelector;
import compiler.cs.compilation.preprocessing.CompilerParameters;
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

	var params :CompilerParameters;

	public function new(cmd:CommandLine, ?system:System, ?logger:Logger)
	{
		this.cmd = cmd;
		this.system = if(system != null) system else new StdSystem();
		this.logger = if(logger != null) logger else new Logger();

		var builder = CompilersBuilder.builder(this.system, this.logger);

		this.compilers = [
			builder.customCompiler(),
			builder.msvcCompiler(),
			builder.monoCompiler()
		];

		this.csSelector	   = new CompilerSelector();	
		this.paramParser   = new ParametersParser(this.system);
	}

	override public function compile(data:Data):Void
	{
		var params = preProcess(data);
		createBuildDirectory();

		var compiler = findCompiler();
		compiler.compile(params);
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
		return this.csSelector.selectFrom(compilers, params);
	}
}
