package hxcs.tests.compiler;

import compiler.cs.implementation.classic.CsProjWriter;
import compiler.cs.compilation.CompilerParameters;
import hxcs.helpers.DataGenerator;
import haxe.io.BytesOutput;
import hxcs.fakes.SystemFake;

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
	var system:SystemFake;

	var writenProject:String;

	public function new() {
	}

	@Before
	public function setup() {
		system = new SystemFake();
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
		writingProject();

		//then:
		var type = params.islibrary ? 'Library' : 'Exe';
		projectShouldContain('<OutputType>$type</OutputType>');
		projectShouldContain('<AssemblyName>${params.name}</AssemblyName>');
		projectShouldContain('<TargetFrameworkVersion>v${params.versionStr}</TargetFrameworkVersion>');

		if(params.unsafe){
			projectShouldContain('<AllowUnsafeBlocks>true</AllowUnsafeBlocks>');
		}

		for(lib in regularLibs.keys()){
			projectShouldContain('<Reference Include="${lib}" />');
		}
		for(lib=>hint in localLibs.keyValueIterator()){
			projectShouldContain('<Reference Include="${lib}">');
			projectShouldContain('<HintPath>${hint}</HintPath>');
		}
	}

	function projectShouldContain(text:String) {
		assertThat(writenProject, containsString(text),
			'Missing expected text on written project');
	}

	function givenParameters(params:CompilerParameters) {
		var data = DataGenerator.defaultData();

		this.params = params;
		this.params.data = data;
	}

	function writingProject() {
		writer.write(params);

		writenProject = output.getBytes().toString();
	}
}