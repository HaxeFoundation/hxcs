package hxcs.tests.implementation.dotnet;

import hxcs.helpers.CompilerParametersGenerator;
import compiler.cs.compilation.pipeline.CompilerFinder;
import compiler.cs.implementation.dotnet.DotnetDefines;
import compiler.cs.implementation.dotnet.DotnetCompilerFinder;

import org.hamcrest.Matchers.*;

using hxcs.fakes.FakeCompilerTools;


class DotnetFinderTest extends CompilerFinderBaseTest{
	static final DotnetCompiler = DotnetCompilerFinder.COMPILER_CMD;
	static final CheckDotnetArgs = DotnetCompilerFinder.CHECK_COMPILER_ARGS;



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

		var compiler = compilerFinder.findCompiler(CompilerParametersGenerator.parametersWithData({
			defines: [DotnetDefines.Enabler => true]
		}));

		fakeSys.shouldCheckCompiler(DotnetCompiler, CheckDotnetArgs);

		fakeSys.foundCompilerShouldBe(compiler, DotnetCompiler);
	}

	@Test
	public function by_default_should_not_select_compiler_if_dotnet_not_enabled() {
		fakeSys.givenCompiler(DotnetCompiler, CheckDotnetArgs);

		var found = compilerFinder.findCompiler(givenParameters());

		assertThat(found, is(nullValue()),
			'Should not select compiler if ${DotnetDefines.Enabler} is not defined');
	}

	@Test
	public function should_search_if_configured_to_ignore_dotnet_enabler() {
		this.compilerFinder = new DotnetCompilerFinder(fakeSys, {
			requireDotnetEnabler: false
		});

		fakeSys.givenCompiler(DotnetCompiler, CheckDotnetArgs);

		var found = compilerFinder.findCompiler(givenParameters());

		fakeSys.foundCompilerShouldBe(found, DotnetCompiler);
		fakeSys.shouldCheckCompiler(DotnetCompiler, CheckDotnetArgs);
	}
}