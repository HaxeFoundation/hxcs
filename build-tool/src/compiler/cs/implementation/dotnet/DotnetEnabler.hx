package compiler.cs.implementation.dotnet;

import compiler.cs.compilation.CompilerParameters;
import compiler.cs.compilation.pipeline.EnvironmentConfigurator;

class DotnetEnabler implements EnvironmentConfigurator{
    public function new() {
    }

    public function configure(params:CompilerParameters):CompilerParameters {
        var clone = params.clone();

        clone.dotnetCore = true;

        return clone;
    }
}