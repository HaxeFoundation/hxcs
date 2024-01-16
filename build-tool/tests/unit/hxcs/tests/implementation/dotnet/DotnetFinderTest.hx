package hxcs.tests.implementation.dotnet;

import compiler.cs.implementation.dotnet.DotnetCompilerFinder;
import compiler.cs.compilation.pipeline.CompilerFinder;

using hxcs.fakes.FakeCompilerTools;


class DotnetFinderTest extends CompilerFinderBaseTest{
	static final DotnetCompiler = 'dotnet';
	static final CheckDotnetArgs = ['--list-sdks'];



	@Before
	public override function setup() {
		super.setup();
	}

	public override function makeCompilerFinder():CompilerFinder {
		return new DotnetCompilerFinder(fakeSys);
	}

	@Test
	public function select_compiler() {
		fakeSys.givenCompiler(DotnetCompiler, CheckDotnetArgs);

		var compiler = compilerFinder.findCompiler(givenParameters());

		fakeSys.shouldCheckCompiler(DotnetCompiler, CheckDotnetArgs);

		fakeSys.foundCompilerShouldBe(compiler, DotnetCompiler);
	}
}