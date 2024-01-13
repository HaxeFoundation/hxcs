package compiler.cs.implementation.classic;

import compiler.cs.compilation.pipeline.ArgumentsGenerator;
import compiler.cs.compilation.CompilerParameters;
import compiler.cs.tools.Logger;
import compiler.cs.system.System;

class CompilerArgsGenerator implements ArgumentsGenerator{
	var system:System;
	var logger:Logger;

	public function new(system:System, logger:Logger) {
		this.system = system;
		this.logger = logger;
	}

	@:access(haxe.io.Path.escape)
	public function generateArgs(params: CompilerParameters) {
		var localLibs = if(params == null) [] else [
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
		if (data.main != null && !params.dll) {
			var idx = data.main.lastIndexOf(".");
			var namespace = data.main.substring(0, idx + 1);
			var main = data.main.substring(idx + 1);
			args.push('/main:' + namespace + (main == "Main" ? "EntryPoint__Main" : main));
		}
		for (libpath in localLibs)
		{
			args.push('/reference:$libpath');
		}
		for (res in data.resources) {
			res = haxe.io.Path.escape(res, true);
			// res = haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(res));
			args.push('/res:src' + delim + 'Resources' + delim + res + ",src.Resources." + res);
		}
		for (file in data.modules)
			args.push("src" + delim + file.path.split(".").join(delim) + ".cs");

		for (opt in data.opts)
			args.push(opt);

		return args;
	}

	function log(text:String, ?pos: haxe.PosInfos) {
		this.logger.log(text, pos);
	}
}