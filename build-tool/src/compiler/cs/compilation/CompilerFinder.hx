package compiler.cs.compilation;

import compiler.cs.compilation.preprocessing.CompilerParameters;

interface CompilerFinder {
    function findCompiler(params:CompilerParameters): Null<String>;
}