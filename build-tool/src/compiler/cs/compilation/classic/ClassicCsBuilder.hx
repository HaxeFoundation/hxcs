package compiler.cs.compilation.classic;

import compiler.cs.tools.Logger;
import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.system.System;
import compiler.cs.compilation.CsBuilder;

class ClassicCsBuilder implements CsBuilder{
	public static final StoredArgs = '@cmd';

    var system:System;
    var logger:Logger;

    public function new(system:System, ?logger:Logger) {
        this.system = system;
        this.logger = logger;
    }

    public function build(command:String, args:Array<String>, ?params:CompilerParameters) {
        log('cmd arguments:  ${args.join(" ")}');

		var ret = 0;
		try
		{
			if (system.systemName() == "Windows" && !hasDefine(params, "LONG_COMMAND_LINE"))
			{
				//save in a file
				system.saveContent('cmd', args.join('\n'));
				args = ['@cmd'];
			}

			if (params != null && params.verbose)
				system.println(command + " " + args.join(" "));

			ret = system.command(command, args);
		}
		catch (e)
		{
			throw Error.CompilerNotFound;
		}

		if (ret != 0)
			throw Error.BuildFailed;
    }

    function log(text:String, ?pos:haxe.PosInfos) {
        if(logger != null) logger.log(text, pos);
    }

    function hasDefine(params:CompilerParameters, defineName:String) {
        if(params == null || params.data == null || params.data.defines == null){
            return false;
        }

        return params.data.defines.exists("LONG_COMMAND_LINE");
    }
}