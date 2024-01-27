package compiler.cs.implementation.classic;

import compiler.cs.compilation.pipeline.ArgumentsGenerator;
import compiler.cs.compilation.CompilerParameters;
import compiler.cs.tools.Logger;
import compiler.cs.system.System;

using compiler.cs.tools.ParametersTools;

class CompilerArgsGenerator implements ArgumentsGenerator{
	var system:System;
	var logger:Logger;

	public function new(system:System, logger:Logger) {
		this.system = system;
		this.logger = logger;
	}

	@:access(haxe.io.Path.escape)
	public function generateArgs(params: CompilerParameters) {
		var localLibs = if(params == null || params.libs == null) [] else [
			for(lib in params.libs) if(lib.hint != null) lib.hint
		];

		var delim = system.systemName() == "Windows" ? "\\" : "/";

		var data = params.data;

		var args = ['/nologo',
					'/optimize' + (params.debug ? '-' : '+'),
					'/debug' + (params.debug ? '+' : '-'),
					'/unsafe' + (params.unsafe ? '+' : '-'),
					'/warn:' + (params.warn ? '1' : '0'),
					'/out:' + params.output + "." + (params.dll ? "dll" : "exe"),
					'/target:' + (params.dll ? "library" : "exe") ];
		if(params.arch != null)
			args.push('/platform:${params.arch}');
		log('preparing cmd arguments:  ${args.join(" ")}');
		if (params.main != null && !params.dll) {
			args.push('/main:' + params.mainClass());
		}
		for (libpath in localLibs)
		{
			args.push('/reference:$libpath');
		}
		for (res in data.resources) {
			res = haxe.io.Path.escape(res, true);

			args.push('/res:src' + delim + 'Resources' + delim + res + ",src.Resources." + res);
		}
		for (file in data.modules)
			args.push("src" + delim + file.path.split(".").join(delim) + ".cs");

		for (opt in data.opts)
			args.push(opt);

		return args;
	}

	function log(text:String, ?pos: haxe.PosInfos) {
		if(logger != null)
			this.logger.log(text, pos);
	}
}