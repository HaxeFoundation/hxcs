package compiler.cs.implementation.dotnet;

import compiler.cs.compilation.CompilerParameters;
import compiler.cs.implementation.common.BaseCompilerFinder;

using compiler.cs.tools.CompilerTools;

class DotnetCompilerFinder extends BaseCompilerFinder{
	static final DOTNET_TOOL = 'dotnet';
	static final CHECK_DOTNET_ARGS = ['--list-sdks'];

	public override function findCompiler(params:CompilerParameters):Null<String> {
		return system.checkCompiler(DOTNET_TOOL, CHECK_DOTNET_ARGS);
	}
}