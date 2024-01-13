import massive.munit.TestSuite;

import hxcs.tests.system.SystemToolsTest;
import hxcs.tests.implementation.classic.finders.MsvcCompilerFinderTest;
import hxcs.tests.implementation.classic.finders.CompilerFinderBaseTest;
import hxcs.tests.implementation.classic.finders.MonoCompilerFinderTest;
import hxcs.tests.implementation.classic.ClassicCsBuilderTest;
import hxcs.tests.compiler.ProjectWriterTest;
import hxcs.tests.compiler.CsProjWriterTest;
import hxcs.tests.compiler.CompilerTest;
import hxcs.tests.compiler.PreProcessCompilerTest;
import hxcs.tests.compilation.CompilerPipelineTest;
import hxcs.tests.compilation.CompilerSelectorTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class TestSuite extends massive.munit.TestSuite
{
	public function new()
	{
		super();

		add(hxcs.tests.system.SystemToolsTest);
		add(hxcs.tests.implementation.classic.finders.MsvcCompilerFinderTest);
		add(hxcs.tests.implementation.classic.finders.CompilerFinderBaseTest);
		add(hxcs.tests.implementation.classic.finders.MonoCompilerFinderTest);
		add(hxcs.tests.implementation.classic.ClassicCsBuilderTest);
		add(hxcs.tests.compiler.ProjectWriterTest);
		add(hxcs.tests.compiler.CsProjWriterTest);
		add(hxcs.tests.compiler.CompilerTest);
		add(hxcs.tests.compiler.PreProcessCompilerTest);
		add(hxcs.tests.compilation.CompilerPipelineTest);
		add(hxcs.tests.compilation.CompilerSelectorTest);
	}
}
