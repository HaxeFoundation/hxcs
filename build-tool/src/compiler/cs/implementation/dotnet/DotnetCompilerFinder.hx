package compiler.cs.implementation.dotnet;

import compiler.cs.compilation.CompilerParameters;
import compiler.cs.implementation.common.BaseCompilerFinder;

using compiler.cs.tools.CompilerTools;

class DotnetCompilerFinder extends BaseCompilerFinder{
	public static final COMPILER_CMD = 'dotnet';
	public static final CHECK_COMPILER_ARGS = ['--list-sdks'];

	public override function findCompiler(params:CompilerParameters):Null<String> {
		return system.checkCompiler(COMPILER_CMD, CHECK_COMPILER_ARGS);
	}
}