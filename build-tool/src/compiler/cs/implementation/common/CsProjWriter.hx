package compiler.cs.implementation.common;

import compiler.cs.compilation.CompilerParameters;
import haxe.io.Bytes;
import haxe.io.Output;
import haxe.io.Path;
import haxe.Resource;
import haxe.Template;
import haxe.crypto.Base64;

using Lambda;

class CsProjWriter
{
	var stream:Output;
	public function new(stream:Output)
	{
		this.stream = stream;
	}

	public function write(params:CompilerParameters):Void
	{
		var versionStr : String = (params.version == null ? "3.5" : Std.string(params.version / 10));
		if (versionStr.indexOf(".") < 0) {
			versionStr += ".0";
		}
		var template = new Template( Resource.getString("csproj-template.mtt") );
		stream.writeString(template.execute( {
			outputType : (params.dll ? "Library" : "Exe"),
			name : params.name,
			dotnetCore: params.dotnetCore,
			targetFramework : versionStr,
			unsafe : params.unsafe,
			refs : params.libs,
			srcs : params.data.modules.map(function(m) return "src\\" + m.path.split(".").join("\\") + ".cs"),
			res : params.data.resources.map(function(res) return resourcePath(res, params))
		} ));
	}

	function resourcePath(res:String, params:CompilerParameters) {
		var resource = (params.dotnetCore) ? res : Base64.encode(Bytes.ofString(res));

		return Path.join(["src", "Resources", resource]);
	}

}