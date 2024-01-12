package compiler.cs.compilation;

import compiler.cs.compilation.preprocessing.CompilerParameters;

interface CsBuilder {
    function build(command:String, args:Array<String>, ?params:CompilerParameters):Void;
}