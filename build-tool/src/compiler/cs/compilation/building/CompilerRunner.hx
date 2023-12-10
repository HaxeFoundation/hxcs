package compiler.cs.compilation.building;

import compiler.cs.compilation.preprocessing.CompilerParameters;

interface CompilerRunner {
    function compile(params:CompilerParameters):Void;
    function build(args:Array<String>):Void;
}