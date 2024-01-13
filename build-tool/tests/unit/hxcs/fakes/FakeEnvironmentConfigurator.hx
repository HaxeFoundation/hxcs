package hxcs.fakes;

import compiler.cs.compilation.CompilerParameters;
import compiler.cs.compilation.pipeline.EnvironmentConfigurator;

import org.hamcrest.Matchers.*;


class FakeEnvironmentConfigurator implements EnvironmentConfigurator{
	public var capturedParameters:Null<CompilerParameters> = null;
	public var replacedParameters:Null<CompilerParameters> = null;

	var configuredCalled:Bool = false;

	public function new() {
	}

	public function configure(params:CompilerParameters):CompilerParameters {
		configuredCalled = true;
		this.capturedParameters = params;

		if(replacedParameters != null){
			return replacedParameters;
		}

		return capturedParameters;
	}

	public function replaceParametersWith(params:CompilerParameters) {
		this.replacedParameters = params;
	}

	public function assertCalledWith(expected:CompilerParameters) {
		assertThat(configuredCalled, is(true), "Configure was not called");
		assertThat(capturedParameters, equalTo(expected),
			"CompilerParameters used in configuration is not what expected");
	}
}