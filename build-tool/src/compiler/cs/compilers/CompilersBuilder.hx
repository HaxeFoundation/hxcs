package compiler.cs.compilers;

import compiler.cs.compilation.finders.CustomCompilerFinder;
import compiler.cs.compilation.finders.MsvcCompilerFinder;
import compiler.cs.compilation.building.CompilerArgsGenerator;
import compiler.cs.compilation.project.ProjectGenerator;
import compiler.cs.compilation.CompilerFinder;
import compiler.cs.tools.Logger;
import compiler.cs.system.System;
import compiler.cs.compilation.finders.MonoCompilerFinder;

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
            new ProjectGenerator(sys, log),
            new CompilerArgsGenerator(sys,log),
            null
        );
    }
}