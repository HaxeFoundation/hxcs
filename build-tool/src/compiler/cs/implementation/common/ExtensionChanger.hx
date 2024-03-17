package compiler.cs.implementation.common;

import compiler.cs.compilation.pipeline.CompilerPipeline.AfterBuildCallback;
import haxe.io.Path;
import compiler.cs.compilation.CompilerParameters;
import compiler.cs.compilation.CompilerDefines;
import compiler.cs.system.System;

class ExtensionChanger {
	public static function afterBuildCallback(sys:System):AfterBuildCallback{
		return (params)->{
			new ExtensionChanger(sys).apply(params);
		};
	}

	var sys:System;

	public function new(sys:System) {
		this.sys = sys;
	}

	public function apply(params:CompilerParameters) {
		if(params.isDefined(CompilerDefines.OutputExtension)){
			var ext = params.getDefinesData(CompilerDefines.OutputExtension);

			var outWithExt = Path.withExtension(params.output, ext);

			this.sys.rename(params.output, outWithExt);
		}
	}
}