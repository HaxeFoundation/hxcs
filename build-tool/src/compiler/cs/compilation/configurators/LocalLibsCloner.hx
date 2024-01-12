package compiler.cs.compilation.configurators;

import compiler.cs.tools.Logger;
import compiler.cs.system.System;
import compiler.cs.compilation.preprocessing.CompilerParameters;

using compiler.cs.compilation.building.CompilationTools;


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