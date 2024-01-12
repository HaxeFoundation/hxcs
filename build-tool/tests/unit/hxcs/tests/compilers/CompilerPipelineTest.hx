package hxcs.tests.compilers;

import compiler.cs.compilation.EnvironmentConfigurator;
import hxcs.fakes.FakeBuilder;
import hxcs.fakes.FakeArgumentsGenerator;
import hxcs.fakes.FakeProjectWriter;
import hxcs.fakes.FakeCompilerFinder;
import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.compilers.CompilerPipeline;
import compiler.cs.compilers.CsCompiler;
import compiler.Error;

import org.hamcrest.Matchers.*;
import hxcs.helpers.ExceptionAssertions.*;


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


class CompilerPipelineTest{
	var compiler:CsCompiler;

	var fakeFinder:FakeCompilerFinder;
	var fakeProjWriter:FakeProjectWriter;
	var fakeArgsGenerator:FakeArgumentsGenerator;
	var fakeBuilder:FakeBuilder;
	var fakeConfigurer:FakeEnvironmentConfigurator;

	var found:Bool;
	var buildParams:CompilerParameters;


	public function new()
	{}

	@Before
	public function setup() {
		fakeFinder = new FakeCompilerFinder();
		fakeProjWriter = new FakeProjectWriter();
		fakeArgsGenerator = new FakeArgumentsGenerator();
		fakeBuilder = new FakeBuilder();
		fakeConfigurer = new FakeEnvironmentConfigurator();

		compiler = new CompilerPipeline(
			fakeFinder, fakeProjWriter, fakeArgsGenerator, fakeBuilder, fakeConfigurer
		);
	}

	@Test
	public function find_compiler() {
		//Given:
		fakeFinder.findReturns("any compiler");

		//When
		when_finding_compiler();

		//Then
		found_compiler_should_be(true);

		// And:
		should_find_compiler();
	}

	@Test
	public function find_compiler_on_build_if_needed() {
		fakeFinder.findReturns(anyCompiler());

		when_compiling_with(anyParam());

		should_find_compiler();
	}

	@Test
	public function should_not_find_compiler_on_build_if_already_found() {
		given_a_compiler_was_found();

		when_compiling_with(anyParam());

		should_find_compiler_once();
	}

	@Test
	public function when_compiling_should_throw_if_compiler_was_not_found() {
		fakeFinder.findReturns(null);

		shouldThrow(
			()->when_compiling_with(anyParam()),
			equalTo(Error.CompilerNotFound)
		);
	}

	@Test
	public function compile_project() {
		given_a_compiler_was_found();

		when_compiling_with(anyParam());

		//Then:
		fakeProjWriter.projectShouldHaveBeenWritten();

		//And:
		fakeArgsGenerator.assertGeneratedArgsWith(buildParams);

		//And:
		fakeBuilder.projectShouldBeBuiltWith(
			foundCompiler(), genArgs(), buildParams);
	}

	@Test
	public function configure_environment() {
		given_a_compiler_was_found();

		given_configurer_changes_parameter_to(paramsWith({
			main: "otherMain"
		}));

		when_compiling_with(anyParam());

		//Then:
		fakeConfigurer.assertCalledWith(buildParams);

		//And:
		fakeBuilder.projectShouldBeBuiltWith(
			foundCompiler(), genArgs(), fakeConfigurer.replacedParameters
		);
	}

	// -----------------------------------------------------------

	function anyParam(): CompilerParameters {
		return {};
	}

	function paramsWith(param:CompilerParameters) {
		return param.clone();
	}

	function anyCompiler() {
		return "any-compiler";
	}

	// -----------------------------------------------------------

	function foundCompiler() {
		return fakeFinder.foundCompiler;
	}

	function genArgs() {
		return fakeArgsGenerator.returnedArgs;
	}

	// -----------------------------------------------------------


	function given_a_compiler_was_found() {
		fakeFinder.findReturns(anyCompiler());

		when_finding_compiler();
	}

	function given_configurer_changes_parameter_to(params:CompilerParameters) {
		fakeConfigurer.replaceParametersWith(params);
	}

	function when_finding_compiler() {
		found = compiler.findCompiler(anyParam());
	}

	function when_compiling_with(params:CompilerParameters) {
		buildParams = params;

		compiler.compile(params);
	}

	function found_compiler_should_be(shouldBe:Bool) {
		assertThat(found, is(shouldBe), 'Find compiler should be: $shouldBe');
	}

	function should_find_compiler() {
		assertThat(compiler.compiler,
			equalTo(fakeFinder.foundCompiler));
	}

	function should_find_compiler_once() {
		fakeFinder.findShouldBeCalled(1);
	}
}