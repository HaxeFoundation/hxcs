package hxcs.tests.implementation.common;

import compiler.cs.implementation.common.CsProjWriter;
import compiler.cs.compilation.CompilerParameters;
import hxcs.helpers.DataGenerator;
import haxe.io.BytesOutput;

import org.hamcrest.Matchers.*;

using hxcs.fakes.FakeCompilerTools;


@:structInit
class WriteProjectParams{
	public var name:String='example';
	public var islibrary:Bool = true;
	public var unsafe:Bool = true;
	public var versionStr:String = '5.0';
	@:optional
	public var regularLibs:Map<String, String>;
	@:optional
	public var localLibs:Map<String, String>;
}

class CsProjWriterTest {
	var writer:CsProjWriter;
	var output:BytesOutput;
	var params:CompilerParameters = null;

	var writenProject:String;

	public function new() {
	}

	@Before
	public function setup() {
		output = new BytesOutput();
		writer = new CsProjWriter(output);
	}

	@Test
	public function write_project() {
		test_write_project({
			islibrary: true,
			versionStr: '5.0',
			unsafe: true,
			regularLibs: ['regularlib' => null],
			localLibs: ['locallib' => 'locallib.dll', 'withpath' => 'example/withpath.dll']
		});
		test_write_project({
			islibrary: false,
			versionStr: '3.5',
			unsafe: false
		});
	}
	function test_write_project(params:WriteProjectParams){
		setup();

		var version = Std.int(Std.parseFloat(params.versionStr) * 10);
		var regularLibs = if(params.regularLibs != null) params.regularLibs else new Map<String, String>();
		var localLibs = if(params.localLibs != null) params.localLibs else new Map<String, String>();
		var libs = [
			for(libmap in [regularLibs, localLibs])
				for(key=>value in libmap.keyValueIterator())
					{name:key, hint:value}
		];

		givenParameters({
			dll: params.islibrary,
			name: params.name,
			version: version,
			unsafe: params.unsafe,
			libs: libs
		});

		//when:
		when_writting_project();

		//then:
		var type = params.islibrary ? 'Library' : 'Exe';
		project_should_contain('<OutputType>$type</OutputType>');
		project_should_contain('<AssemblyName>${params.name}</AssemblyName>');
		project_should_contain('<TargetFrameworkVersion>v${params.versionStr}</TargetFrameworkVersion>');

		if(params.unsafe){
			project_should_contain('<AllowUnsafeBlocks>true</AllowUnsafeBlocks>');
		}

		for(lib in regularLibs.keys()){
			project_should_contain('<Reference Include="${lib}" />');
		}
		for(lib=>hint in localLibs.keyValueIterator()){
			project_should_contain('<Reference Include="${lib}">');
			project_should_contain('<HintPath>${hint}</HintPath>');
		}
	}


	@Test
	public function write_project_for_dotnet_core() {
		givenParameters({
			dotnetCore: true,
			version:80
		});

		// when_writting_project();
		when_writting_project();

		project_should_contain_tag("TargetFramework", "net8.0");
		project_should_not_contain("<TargetFrameworkVersion>");
		project_should_not_contain("<TargetFrameworkProfile>");

		project_should_contain('<Project Sdk="Microsoft.NET.Sdk">');

		project_should_contain_tag("ImplicitUsings", "enable");
		project_should_contain_tag("Nullable","enable");
		project_should_contain_tag("EnableDefaultCompileItems", "false");

		project_should_not_contain('Include="System"');
		project_should_not_contain('Project="$(MSBuildToolsPath)\\Microsoft.CSharp.targets"');
	}

	// ----------------------------------------------------------------------

	function givenParameters(params:CompilerParameters) {
		var data = DataGenerator.defaultData();

		this.params = params;
		this.params.data = data;

		if(this.params.libs == null){
			this.params.libs = [];
		}
	}

	function when_writting_project() {
		writer.write(params);

		writenProject = output.getBytes().toString();
	}

	function project_should_contain_tag(tag:String, value:String) {
		project_should_contain('<$tag>$value</$tag>');
	}

	function project_should_contain(text:String) {
		assertThat(writenProject, containsString(text),
			'Missing expected text on written project');
	}

	function project_should_not_contain(text:String) {
		assertThat(writenProject, not(containsString(text)));
	}
}