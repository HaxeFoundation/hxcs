package compiler.cs.implementation.dotnet;

import haxe.Rest;
import compiler.cs.compilation.CsCompiler;
import compiler.cs.compilation.pipeline.CompilerFinder;
import compiler.cs.compilation.pipeline.ProjectWriter;
import compiler.cs.compilation.pipeline.ArgumentsGenerator;
import compiler.cs.compilation.pipeline.CsBuilder;
import compiler.cs.compilation.pipeline.EnvironmentConfigurator;
import compiler.cs.implementation.common.ExtensionChanger;
import compiler.cs.implementation.common.PipelineCompilerBuilder;
import compiler.cs.implementation.dotnet.DotnetCompilerFinder.DotnetCompilerFinderOptions;
import compiler.cs.system.System;
import compiler.cs.tools.Logger;

class DotnetCoreCompilerBuilder
    extends BasePipelineCompilerBuilder<DotnetCoreCompilerBuilder>
{
    public static function builder(system:System, ?logger:Logger) {
        return new DotnetCoreCompilerBuilder(system, logger);
    }

    var finderOptions:DotnetCompilerFinderOptions;

    public function new(system:System, ?logger:Logger) {
        super(system, logger);

        this.finderOptions = {requireDotnetEnabler: true};

        this.argsGenerator = new DotnetArgsGenerator();
        this.composedConfig.addAll([
            new DotnetEnabler(),
            new DotnetSdkConfigurator(system)
        ]);

        afterBuild(ExtensionChanger.afterBuildCallback(system));
    }

    public function requireEnabler(require:Bool){
        this.finderOptions.requireDotnetEnabler = require;

        return this;
    }

    public override function build(
        ?finder:CompilerFinder,
        ?projectWriter:ProjectWriter,
        ?argsGenerator:ArgumentsGenerator,
        ?csBuilder:CsBuilder,
        configurators:Rest<EnvironmentConfigurator>):CsCompiler
    {
        if(finder == null && this.compilerFinder == null){
            finder = new DotnetCompilerFinder(this.sys, this.log, this.finderOptions);
        }
        return super.build(
            finder, projectWriter, argsGenerator, csBuilder, ...configurators);
    }
}