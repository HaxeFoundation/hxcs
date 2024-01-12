import massive.munit.TestSuite;

import hxcs.tests.compilers.CompilerPipelineTest;
import hxcs.tests.system.SystemToolsTest;
import hxcs.tests.compiler.ProjectWriterTest;
import hxcs.tests.compiler.CsProjWriterTest;
import hxcs.tests.compiler.CompilerTest;
import hxcs.tests.compiler.PreProcessCompilerTest;
import hxcs.tests.compiler.CompilerSelectorTest;
import hxcs.tests.compilation.finders.MsvcCompilerFinderTest;
import hxcs.tests.compilation.finders.CompilerFinderBaseTest;
import hxcs.tests.compilation.finders.MonoCompilerFinderTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class TestSuite extends massive.munit.TestSuite
{
	public function new()
	{
		super();

		add(hxcs.tests.compilers.CompilerPipelineTest);
		add(hxcs.tests.system.SystemToolsTest);
		add(hxcs.tests.compiler.ProjectWriterTest);
		add(hxcs.tests.compiler.CsProjWriterTest);
		add(hxcs.tests.compiler.CompilerTest);
		add(hxcs.tests.compiler.PreProcessCompilerTest);
		add(hxcs.tests.compiler.CompilerSelectorTest);
		add(hxcs.tests.compilation.finders.MsvcCompilerFinderTest);
		add(hxcs.tests.compilation.finders.CompilerFinderBaseTest);
		add(hxcs.tests.compilation.finders.MonoCompilerFinderTest);
	}
}
