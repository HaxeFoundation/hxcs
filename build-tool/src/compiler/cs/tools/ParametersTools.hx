package compiler.cs.tools;

import compiler.cs.compilation.CompilerParameters;

using StringTools;

class ParametersTools {
    public static function mainClass(parameters:CompilerParameters) {
        if(parameters == null || parameters.main == null){
            return null;
        }

        var main = parameters.main;

        return main.endsWith("Main")
                ? replaceMainWithEntryPoint(main)
                : main;
    }

    static function replaceMainWithEntryPoint(main:String) {
        var nameParts = main.split('.');
        var lastIdx = nameParts.length - 1;

        if (nameParts[lastIdx] == "Main"){
            nameParts[lastIdx] = "EntryPoint__Main";
        }

        return nameParts.join('.');
    }
}