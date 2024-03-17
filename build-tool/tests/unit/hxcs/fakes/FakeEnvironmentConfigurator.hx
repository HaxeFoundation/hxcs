package hxcs.fakes;

import compiler.cs.compilation.CompilerParameters;
import compiler.cs.compilation.pipeline.EnvironmentConfigurator;


class FakeEnvironmentConfigurator implements EnvironmentConfigurator{
	public var capturedParameters(get, null):Null<CompilerParameters> = null;
	public var replacedParameters(default, null):Null<CompilerParameters> = null;

	var fakeCallback:FakeCallback<CompilerParameters>;

	var configuredCalled:Bool = false;

	public function new() {
		fakeCallback = new FakeCallback();
	}

	function get_capturedParameters() {
		return fakeCallback.capturedParameters;
	}

	public function configure(params:CompilerParameters):CompilerParameters {
		fakeCallback.call(params);

		if(replacedParameters != null){
			return replacedParameters;
		}

		return fakeCallback.capturedParameters;
	}

	public function replaceParametersWith(params:CompilerParameters) {
		this.replacedParameters = params;
	}

	public function assertCalledWith(expected:CompilerParameters) {
		fakeCallback.assertCalledWith(expected);
	}
}