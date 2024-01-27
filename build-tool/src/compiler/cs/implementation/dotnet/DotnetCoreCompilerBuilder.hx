package compiler.cs.implementation.dotnet;

import compiler.cs.implementation.common.ComposedConfigurator;
import compiler.cs.system.System;
import compiler.cs.tools.Logger;
import compiler.cs.implementation.common.PipelineCompilerBuilder;

class DotnetCoreCompilerBuilder extends PipelineCompilerBuilder{
    public static function builder(system:System, ?logger:Logger) {
        return new DotnetCoreCompilerBuilder(system, logger);
    }

    public function new(system:System, ?logger:Logger) {
        super(system, logger);
        this.argsGenerator = new DotnetArgsGenerator();
        this.compilerFinder = new DotnetCompilerFinder(system, logger);
        this.composedConfig.addAll([
            new DotnetEnabler(),
            new DotnetSdkConfigurator(system)
        ]);
    }
}