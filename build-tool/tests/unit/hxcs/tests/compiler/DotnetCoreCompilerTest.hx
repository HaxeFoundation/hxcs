package hxcs.tests.compiler;

import haxe.io.Path;
import compiler.cs.compilation.CsCompiler;
import compiler.cs.compilation.CompilerParameters;
import compiler.cs.compilation.pipeline.EnvironmentConfigurator;
import compiler.cs.implementation.dotnet.DotnetCompilerFinder;
import compiler.cs.implementation.dotnet.DotnetCoreCompilerBuilder;
import compiler.cs.implementation.dotnet.DotnetDefines;
import compiler.cs.implementation.dotnet.DotnetSdkConfigurator.SdkInfo;

import org.hamcrest.Matchers.*;

using hxcs.fakes.FakeCompilerTools;


class DotnetCoreCompilerTest extends BaseCompilerTests{
	static final DOTNET_CMD = DotnetCompilerFinder.COMPILER_CMD;
	static final DOTNET_CHECK_ARGS = DotnetCompilerFinder.CHECK_COMPILER_ARGS;

	var paramsCatcher:CompilerParametersCatcher;

	@Before
	public override function setup() {
		super.setup();

		paramsCatcher = new CompilerParametersCatcher();
	}

	@Test
	public function compile_with_dotnet_if_enabled() {
		givenCsCompilers([
			dotnetCompilerBuilder().build()
		]);
		givenDotnetCoreSdk('8.0.0');
		givenDataWith({
			defines: [
				DotnetDefines.Enabler => true
			]
		});

		when_compiling();

		shouldCompileWithDotnet(80);
	}


	@Test
	public function compile_with_dotnet_if_not_requires_enabler() {
		givenCsCompilers([
			dotnetCompilerBuilder()
				.requireEnabler(false)
				.build()
		]);
		givenDotnetCoreSdk('8.0.0');
		givenDataWith({
			defines: [
				DotnetDefines.Enabler => true
			]
		});

		when_compiling();

		shouldCompileWithDotnet(80);
	}


	@Test
	public function select_dotnet_when_enabled_in_defines() {
		givenCompilers(['mcs', 'dmcs', 'gmcs']);
		givenDotnetCoreSdk('7.0.2');
		givenDataWith({
			defines: [DotnetDefines.Enabler => true]
		});

		when_compiling();
		shouldSelectCompiler(DOTNET_CMD, DOTNET_CHECK_ARGS);
	}

	@Test
	public function select_dotnet_when_there_is_no_other_compiler() {
		givenDotnetCoreSdk('7.0.2');
		when_compiling();
		shouldSelectCompiler(DOTNET_CMD, DOTNET_CHECK_ARGS);
	}

	@Test
	public function select_other_compilers_by_default() {
		givenDotnetCoreSdk('7.0.2');
		givenCompilers(['mcs', 'dmcs', 'gmcs']);

		when_compiling();

		shouldSelectCompiler('mcs', ['-help']);
	}

	// ----------------------------------------------------------------

	function dotnetCompilerBuilder(): DotnetCoreCompilerBuilder {
		return cast DotnetCoreCompilerBuilder
			.builder(this.fakeSys)
			.addConfigurator(paramsCatcher);
	}

	function givenCsCompilers(arr:Array<CsCompiler>) {
		this.compiler.compilers = arr;
	}

	function givenDotnetCoreSdk(sdk:String) {
		givenCompiler(DOTNET_CMD, DOTNET_CHECK_ARGS);

		var command = fakeSys.compilerWithExtension(DOTNET_CMD);

		fakeSys.givenProcess(command, ['--list-sdks']).output(
			new SdkInfo(sdk, Path.join(['any', 'path'])).toString()
		).setExitCode(0);
	}

	function shouldCompileWithDotnet(version:Int) {
		shouldUseCompilerWith(DOTNET_CMD, DOTNET_CHECK_ARGS);
		shouldUseCompilerWith(DOTNET_CMD, (cmdSpec)->{
			return cmdSpec.args.contains('build');
		});
		should_configure_parameters_with({
			version: version,
			dotnetCore: true
		});
	}


	function when_compiling() {
		compiler.compile(data);
	}

	function should_configure_parameters_with(params:Dynamic) {
		var capturedParams = this.paramsCatcher.capturedParams;

		assertThat(capturedParams, is(notNullValue()), "Missing captured params");

		for (field in Reflect.fields(params)){
			var expectedValue = Reflect.field(params, field);
			if(expectedValue != null){
				var paramsValue = Reflect.field(capturedParams, field);

				assertThat(paramsValue, equalTo(expectedValue),
					'Parameter $field should be $expectedValue. In: $capturedParams'
				);
			}
		}
	}
}

class CompilerParametersCatcher implements EnvironmentConfigurator{

	public var capturedParams(default, null): CompilerParameters;

	public function new() {
	}

	public function configure(params:CompilerParameters):CompilerParameters {
		this.capturedParams = params;

		return params;
	}
}