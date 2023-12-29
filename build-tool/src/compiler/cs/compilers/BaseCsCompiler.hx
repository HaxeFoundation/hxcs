package compiler.cs.compilers;

import compiler.cs.tools.Logger;
import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.system.System;

using compiler.cs.compilers.CompilerTools;

class BaseCsCompiler implements CsCompiler{
    var system:System;
    var logger:Logger;

	public var compiler(default, null):String;

    public function new(system:System, ?logger:Logger) {
        this.system = system;
        this.logger = logger;
    }

    public function findCompiler(params:CompilerParameters):Bool {
        throw new haxe.exceptions.NotImplementedException();
    }


    // -------------------------------------------------------------------------

    function log(text:String, ?pos:haxe.PosInfos) {
        if(logger != null) logger.log(text, pos);
    }

    function exists(exe:String, checkArgs:Array<String> = null) {
        return this.system.compilerExists(exe, checkArgs);
    }
}