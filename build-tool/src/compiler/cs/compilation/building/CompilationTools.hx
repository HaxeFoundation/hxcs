package compiler.cs.compilation.building;

import compiler.cs.tools.Logger;
import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.system.System;
import haxe.io.Path;

using compiler.cs.system.SystemTools;


class CompilationTools {
    public static function copyLibs(
        system:System, params:CompilerParameters, ?logger:Logger): CompilerParameters
    {
		var copyParam = params.clone();
		copyParam.libs = [];
		var data = params.data;

		for (ref in params.libs)
		{
			if (ref.hint != null)
			{
				var fullpath = ref.hint.addBasePath(data.baseDir);
				var mypath   = Path.withoutDirectory(ref.hint).addBasePath(params.outDir);

				log('copying lib from $fullpath to $mypath', logger);
				system.copyIfNewer(fullpath, mypath);

				copyParam.libs.push({
					name: ref.name,
					hint: mypath
				});
			}
		}

		return copyParam;
	}

    static function log(text:String, logger:Null<Logger>) {
        logger.log(text);
    }
}