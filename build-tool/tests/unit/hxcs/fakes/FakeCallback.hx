package hxcs.fakes;

import haxe.PosInfos;

import org.hamcrest.Matchers.*;


class FakeCallback<T>{
	public var capturedParameters(default, null):Null<T> = null;

	var callbackCalled:Bool = false;

	public function new() {
	}

	public function callback(): (T)->Void {
		return this.call;
	}

	public function call(params:T) {
		callbackCalled = true;
		this.capturedParameters = params;
	}

	public function assertCalledWith(expected:T, ?pos:PosInfos) {
		assertThat(callbackCalled, is(true), "Was not called", pos);
		assertThat(capturedParameters, equalTo(expected),
			"Captured parameters does not match expectation", pos);
	}
}