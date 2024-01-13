package compiler.cs.implementation.classic;

import compiler.cs.compilation.pipeline.EnvironmentConfigurator;
import compiler.cs.tools.Logger;
import compiler.cs.system.System;
import compiler.cs.compilation.CompilerParameters;

using compiler.cs.tools.CompilationTools;


class LocalLibsCloner implements EnvironmentConfigurator{
    var system:System;
    var logger:Null<Logger>;

    public function new(system:System, ?logger:Logger) {
        this.system = system;
        this.logger = logger;
    }

    public function configure(params:CompilerParameters):CompilerParameters {
        return system.copyLocalLibs(params, logger);
    }
}