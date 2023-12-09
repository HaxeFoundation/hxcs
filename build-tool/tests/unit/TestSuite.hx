import massive.munit.TestSuite;

import hxcs.tests.system.SystemToolsTest;
import hxcs.tests.compiler.ProjectWriterTest;
import hxcs.tests.compiler.CompilerTest;
import hxcs.tests.compiler.PreProcessCompilerTest;

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
		add(hxcs.tests.compiler.ProjectWriterTest);
		add(hxcs.tests.compiler.CompilerTest);
		add(hxcs.tests.compiler.PreProcessCompilerTest);
	}
}
