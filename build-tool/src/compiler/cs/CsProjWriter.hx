package compiler.cs;
import haxe.io.Output;
import haxe.Resource;
import haxe.Template;

using Lambda;

class CsProjWriter
{
	var stream:Output;
	public function new(stream:Output)
	{
		this.stream = stream;
	}

	public function write(compiler:CSharpCompiler):Void
	{
		var versionStr : String = (compiler.version == null ? "3.5" : Std.string(compiler.version / 10));
		if (versionStr.indexOf(".") < 0) {
			versionStr += ".0";
		}
		var template = new Template( Resource.getString("csproj-template.mtt") );
		stream.writeString(template.execute( {
			outputType : (compiler.dll ? "Library" : "Exe"),
			name : compiler.name,
			targetFramework : versionStr,
			unsafe : compiler.unsafe,
			refs : compiler.libs,
			srcs : compiler.data.modules.map(function(m) return "src\\" + m.path.split(".").join("\\") + ".cs"),
			res : compiler.data.resources.map(function(res) return "src\\Resources\\" + haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(res)))
		} ));
	}

}