package compiler.cs.implementation.classic;

import compiler.cs.implementation.common.ExtensionChanger;
import compiler.cs.compilation.CsCompiler;
import compiler.cs.compilation.pipeline.CompilerFinder;
import compiler.cs.compilation.pipeline.CompilerPipeline;
import compiler.cs.implementation.classic.finders.CustomCompilerFinder;
import compiler.cs.implementation.classic.finders.MonoCompilerFinder;
import compiler.cs.implementation.classic.finders.MsvcCompilerFinder;
import compiler.cs.implementation.common.CsProjectGenerator;
import compiler.cs.implementation.common.DefaultCsBuilder;

import compiler.cs.system.System;
import compiler.cs.tools.Logger;


class CompilersBuilder {
    var sys:System;
    var log:Null<Logger>;

    public function new(system:System, ?logger:Logger) {
        this.sys = system;
        this.log = logger;
    }

    public static function builder(system:System, ?logger:Logger) {
        return new CompilersBuilder(system, logger);
    }

    public function system(system:System) {
        this.sys = system;
        return this;
    }

    public function logger(logger:Null<Logger>) {
        this.log = logger;
        return this;
    }

    public function customCompiler() {
        return build(new CustomCompilerFinder(sys, log));
    }

    public function monoCompiler():CsCompiler {
        return build(new MonoCompilerFinder(sys, log));
    }

    public function msvcCompiler():CsCompiler {
        return build(new MsvcCompilerFinder(sys, log));
    }

    function build(finder:CompilerFinder) {
        return new CompilerPipeline(
            finder,
            new CsProjectGenerator(sys, log),
            new CompilerArgsGenerator(sys,log),
            new DefaultCsBuilder(sys, log),
            new LocalLibsCloner(sys, log),
            ExtensionChanger.afterBuildCallback(sys)
        );
    }
}