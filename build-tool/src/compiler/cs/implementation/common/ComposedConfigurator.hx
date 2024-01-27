package compiler.cs.implementation.common;

import haxe.Rest;
import compiler.cs.compilation.CompilerParameters;
import compiler.cs.compilation.pipeline.EnvironmentConfigurator;

class ComposedConfigurator implements EnvironmentConfigurator{
    var configs:Array<EnvironmentConfigurator>;

    public function new(configs:Rest<EnvironmentConfigurator>) {
        this.configs = configs.toArray();
    }

    public function configure(params:CompilerParameters):CompilerParameters {
        var outParams = params;

        for (c in configs){
            outParams = c.configure(outParams);
        }

        return outParams;
    }

    public function addConfigurator(envConfig:EnvironmentConfigurator) {
        this.configs.push(envConfig);
    }

    public function addAll(configurators:Iterable<EnvironmentConfigurator>) {
        for(config in configurators){
            addConfigurator(config);
        }
    }
}