package compiler.cs.compilation.finders;

import haxe.io.Path;
import compiler.cs.compilation.preprocessing.CompilerParameters;

class MsvcCompilerFinder extends BaseCompilerFinder {

	override public function findCompiler(params:CompilerParameters):Null<String> {
		return findMsvc();
	}

	//  ----------------------------------------------------------------------


	private function findMsvc()
	{
		if (system.systemName() != "Windows")
			return null;

		log('looking for MSVC directory');
		//se if it is in path
		if (exists("csc"))
		{
			log('found csc compiler');
			return Path.withExtension("csc", 'exe');
		}

		return searchCompilerFromWindir();
	}

	function searchCompilerFromWindir() {
		var windir = system.getEnv("windir");
		if (windir == null)
			windir = "C:\\Windows";
		log('WINDIR: ${windir} (${system.getEnv('windir')})');

		for (winsubdir in ["\\Microsoft.NET\\Framework64", "\\Microsoft.NET\\Framework"])
		{
			var foundPath = searchMsvcIn(Path.join([windir, winsubdir]));
			if (foundPath != null)
			{
				return foundPath;
			}
		}

		return null;
	}

	function searchMsvcIn(path:String) {
		log('looking up framework at ' + path);

		var foundVer:Null<Float> = null;
		var foundPath = null;
		if (system.exists(path))
		{
			var regex = ~/v(\d+.\d+)/;
			for (f in system.readDirectory(path))
			{
				if (regex.match(f))
				{
					var ver = Std.parseFloat(regex.matched(1));
					log('found framework: $f (ver $ver)');

					//Try to get greater version of compiler
					if (!Math.isNaN(ver) && (foundVer == null || foundVer < ver))
					{
						var compilerPath = Path.join([path, f, 'csc.exe']);

						if (system.exists(compilerPath))
						{
							log('found path:$compilerPath');
							foundPath = compilerPath;
							foundVer = ver;
						}
					}
				}
			}
		}

		return foundPath;
	}
}