package compiler.cs.implementation.dotnet;

import compiler.cs.tools.Logger;
import compiler.cs.system.System;
import compiler.cs.compilation.CompilerDefines;
import compiler.cs.compilation.CompilerParameters;
import compiler.cs.implementation.common.BaseCompilerFinder;

using compiler.cs.tools.CompilerTools;

typedef DotnetCompilerFinderOptions = {
	requireDotnetEnabler: Bool
};

class DotnetCompilerFinder extends BaseCompilerFinder{
	public static final COMPILER_CMD = 'dotnet';
	public static final CHECK_COMPILER_ARGS = ['--list-sdks'];

	var requireEnabler:Bool = true;

	public function new(sys:System, ?logger:Logger, ?options:DotnetCompilerFinderOptions) {
		super(sys, logger);

		this.requireEnabler = options == null || options.requireDotnetEnabler;
	}

	public override function findCompiler(params:CompilerParameters):Null<String> {
		if(requireEnabler && !params.isDefined(CompilerDefines.DotnetEnabler)){
			log('Did not enabled Dotnet because parameter ${CompilerDefines.DotnetEnabler} was not defined');
			return null;
		}

		return system.checkCompiler(COMPILER_CMD, CHECK_COMPILER_ARGS);
	}
}