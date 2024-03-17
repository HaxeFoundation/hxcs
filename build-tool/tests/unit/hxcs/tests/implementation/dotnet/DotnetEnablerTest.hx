package hxcs.tests.implementation.dotnet;

import hxcs.helpers.CompilerParametersGenerator;
import compiler.cs.implementation.dotnet.DotnetEnabler;

import org.hamcrest.Matchers.*;


class DotnetEnablerTest {
	var dotnetEnabler:DotnetEnabler;

	public function new() {}

	@Before
	public function setup() {
		dotnetEnabler = new DotnetEnabler();
	}

	@Test
	public function should_enable_dotnet_core() {
		// Given
		var initialParams = CompilerParametersGenerator.parametersWith({
			name: 'example',
			dotnetCore: false
		});

		// When
		var params = dotnetEnabler.configure(initialParams);

		//Then
		assertThat(params, is(notNullValue()), 'modified params');
		assertThat(params, is(not(theInstance(initialParams))), 'should not change original instance');
		assertThat(params.dotnetCore, is(true),
			'Should enable dotnet core');
	}
}