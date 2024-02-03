package compiler.cs;

import compiler.cs.implementation.dotnet.DotnetCoreCompilerBuilder;
import compiler.cs.implementation.classic.CompilersBuilder;
import compiler.cs.implementation.common.ParametersParser;
import compiler.cs.compilation.CsCompiler;
import compiler.cs.compilation.CompilerSelector;
import compiler.cs.compilation.CompilerParameters;
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
	var csSelector	 :CompilerSelector;

	public var compilers(default, default):Array<CsCompiler>;

	public function new(cmd:CommandLine, ?system:System, ?logger:Logger)
	{
		this.cmd = cmd;
		this.system = if(system != null) system else new StdSystem();
		this.logger = if(logger != null) logger else new Logger();

		var builder = CompilersBuilder.builder(this.system, this.logger);
		var dotnetBuilder = DotnetCoreCompilerBuilder.builder(this.system, this.logger);

		this.compilers = [
			dotnetBuilder.requireEnabler(true).build(),
			builder.customCompiler(),
			builder.msvcCompiler(),
			builder.monoCompiler(),

			// When no other compiler is found, select dotnet even if not explicitly enabled
			dotnetBuilder.requireEnabler(false).build()
		];

		this.csSelector	   = new CompilerSelector();	
		this.paramParser   = new ParametersParser(this.system);
	}

	override public function compile(data:Data):Void
	{
		var params = preProcess(data);
		createBuildDirectory();

		var compiler = findCompiler(params);
		compiler.compile(params);
	}

	function preProcess(data:Data) {
		var params = paramParser.parse(data, cmd.output);
		logger.verbose = params.verbose;

		return params;
	}

	function createBuildDirectory() {
		// Maybe should create params.outDir (by default is bin, but may be different)
		if (!system.exists("bin"))
			system.createDirectory("bin");
	}

	function findCompiler(params:CompilerParameters){
		return this.csSelector.selectFrom(compilers, params);
	}
}
