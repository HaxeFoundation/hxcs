package compiler.cs.implementation.dotnet;

import compiler.cs.compilation.CompilerParameters;
import compiler.cs.compilation.pipeline.ArgumentsGenerator;

using compiler.cs.tools.ParametersTools;


class DotnetArgsGenerator implements ArgumentsGenerator{
    public function new() {
    }

    public function generateArgs(params:CompilerParameters):Array<String> {
        var args = ["build", params.csProj()];

        extend(args, ['-p:OutputType=${params.dll ? "Library" : "Exe"}']);
        extend(args, ['-p:WarningLevel=${params.warn ? 1 : 0}']);
        extend(args, ['-p:Optimize=${params.debug ? "false" : "true"}']);
        extend(args, ['-p:AllowUnsafeBlocks=${params.unsafe ? "true": "false"}']);

        if(params.outDir != null){
            extend(args, ['-o', params.outDir]);
        }
        if(params.arch != null){
            extend(args, ['--arch', params.arch]);
        }
        if(params.main != null){
            extend(args, ['-p:StartupObject=${params.mainClass()}']);
        }
        if(params.debug){
            extend(args, ['--debug']);
        }

        if(params.data.opts != null){
            extend(args, params.data.opts);
        }

        return args;
    }

    function extend(arr:Array<String>, items:Iterable<String>) {
        for (item in items){
            arr.push(item);
        }
    }
}