package compiler.cs.compilation.pipeline;

import compiler.cs.compilation.CompilerParameters;

interface CsBuilder {
    function build(command:String, args:Array<String>, ?params:CompilerParameters):Void;
}