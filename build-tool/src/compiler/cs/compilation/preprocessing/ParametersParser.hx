package compiler.cs.compilation.preprocessing;

import haxe.io.Path;
import input.Data;
import compiler.cs.system.System;

using compiler.cs.system.SystemTools;


class ParametersParser {
	var  system:System;

	public function new(system:System)
	{
		this.system = system;
	}

	public function parse(data:Data, output:String): CompilerParameters {
		var params:CompilerParameters = {
			name          : extractMain(data),
			main          : data.main,
			version       : extractVersion(data),
			csharpCompiler: data.definesData.get("csharp-compiler"),
			silverlight   : data.defines.exists("silverlight"),
			dll           : data.defines.exists("dll") || data.main == null,
			debug         : getDebug(data),
			unsafe        : data.defines.exists("unsafe"),
			warn          : data.defines.exists("warn"),
			verbose       : data.defines.exists("verbose"),
			arch          : data.definesData.get('arch'),
			libs          : extractLibs(data),
			data          : data
		};

		addOutputInfo(params, data, output);

		return params;
	}

	function getDebug(data:Data) {
		return data.defines.exists("debug");
	}

	function extractMain(data:Data) {
		// get name from main class if there's one
		// or from output directory name if there's none
		var name = null;
		if (data.main != null)
		{
			name = data.main.split('.').pop();
		}
		else
		{
			name = Path.withoutDirectory(system.getCwd());
		}
		if (getDebug(data))
			name += "-Debug";
		
		return name;
	}

	function extractVersion(data:Data) {
		//get requested version
		var version:Null<Int> = null;
		for (ver in [50,45,40,35,30,21,20])
		{
			if (data.defines.exists("NET_" + ver))
			{
				version = ver;
				break;
			}
		}

		return version;
	}

	function extractLibs(data:Data) {
		// massage the library names
		var libs = [];
		for (lib in data.libs)
		{
			var parsed = {name: lib, hint: null};

			if (Path.extension(lib) == "dll")
			{
				parsed.hint = lib;
				parsed.name = Path.withoutExtension(Path.withoutDirectory(lib));
			}

			libs.push(parsed);
		}

		return libs;
	}

	function addOutputInfo(params:CompilerParameters, data:Data, output:String) {
		if(output != null){
			params.output = output.addBasePath(data.baseDir);
			params.outDir = Path.directory(params.output);
		}
		else {
			params.outDir = 'bin';
			params.output = Path.join([params.outDir, params.name]);
		}
	}
}