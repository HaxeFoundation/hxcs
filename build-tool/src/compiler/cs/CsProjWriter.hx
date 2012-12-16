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
		var template = new Template( Resource.getString("csproj-template.mtt") );
		stream.writeString(template.execute( { 
			outputType : (compiler.dll ? "Dll" : "Exe"),
			name : compiler.name,
			targetFramework : (compiler.version == null ? "3.5" : ( (compiler.version / 10) + "" )),
			unsafe : compiler.unsafe,
			srcs : compiler.data.modules.map(function(m) return "src\\" + m.path.split(".").join("\\") + ".cs"),
			res : compiler.data.resources.map(function(res) return "src\\Resources\\" + res)
		} ));
	}
	
}