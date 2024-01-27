package hxcs.tests.compiler;

import compiler.cs.compilation.pipeline.EnvironmentConfigurator;
import compiler.cs.compilation.CompilerParameters;
import haxe.io.Path;
import compiler.cs.implementation.dotnet.DotnetSdkConfigurator.SdkInfo;
import compiler.cs.implementation.dotnet.DotnetCoreCompilerBuilder;

import compiler.cs.implementation.dotnet.DotnetCompilerFinder;

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

		compiler.compilers = [
			DotnetCoreCompilerBuilder
				.builder(this.fakeSys)
				.addConfigurator(paramsCatcher)
				.build()
		];
	}

	@Test
	public function compile_project() {
		givenDotnetCoreSdk('8.0.0');

		when_compiling();

		shouldUseCompilerWith(DOTNET_CMD, DOTNET_CHECK_ARGS);
		shouldUseCompilerWith(DOTNET_CMD, (cmdSpec)->{
			return cmdSpec.args.contains('build');
		});
		should_configure_parameters_with({
			version: 80,
			dotnetCore: true
		});
	}

	function givenDotnetCoreSdk(sdk:String) {
		givenCompiler(DOTNET_CMD, DOTNET_CHECK_ARGS);

		var command = fakeSys.compilerWithExtension(DOTNET_CMD);

		fakeSys.givenProcess(command, ['--list-sdks']).output(
			new SdkInfo(sdk, Path.join(['any', 'path'])).toString()
		).setExitCode(0);
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