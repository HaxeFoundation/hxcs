package compiler.cs.compilation.building;

import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.tools.Logger;
import compiler.cs.compilation.selection.CompilerInfo;
import compiler.cs.system.System;

using compiler.cs.compilation.building.CompilationTools;

class DefaultCompilerRunner implements CompilerRunner{
    var compilerInfo:CompilerInfo;
    var system:System;
    var logger:Logger;
    var params:CompilerParameters;
    var argsGen:CompilerArgsGenerator;

    public function new(
        compilerInfo:CompilerInfo, params:CompilerParameters, system:System, logger:Logger,
        ?argsGen:CompilerArgsGenerator)
    {
        this.compilerInfo = compilerInfo;
        this.params = params;
        this.system = system;
        this.logger = logger;
        this.argsGen = if(argsGen != null) argsGen else new CompilerArgsGenerator(system, logger);
    }

    public function compile(params:CompilerParameters) {
        var copiedParams = system.copyLibs(params, logger);
        var args = argsGen.generateArgs(copiedParams);
        build(args);
    }

	public function build(args:Array<String>) {
		log('cmd arguments:  ${args.join(" ")}');
		var ret = 0;
		try
		{
			if (system.systemName() == "Windows" && !params.data.defines.exists("LONG_COMMAND_LINE"))
			{
				//save in a file
				system.saveContent('cmd', args.join('\n'));
				args = ['@cmd'];
			}

			if (params.verbose)
				system.println(compilerInfo.command + " " + args.join(" "));

			ret = system.command(compilerInfo.command, args);
		}
		catch (e:Dynamic)
		{
			throw Error.CompilerNotFound;
		}

		if (ret != 0)
			throw Error.BuildFailed;
	}

    function log(text:String, ?pos:haxe.PosInfos) {
        this.logger.log(text, pos);
    }
}