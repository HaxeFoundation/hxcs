package compiler.cs.compilation.pipeline;

import compiler.cs.compilation.CompilerParameters;

interface CompilerFinder {
    function findCompiler(params:CompilerParameters): Null<String>;
}