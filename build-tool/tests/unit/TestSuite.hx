import massive.munit.TestSuite;

import hxcs.tests.compilers.MsvcCompilerTest;
import hxcs.tests.compilers.BaseCompilersTest;
import hxcs.tests.compilers.MonoCompilerTest;
import hxcs.tests.system.SystemToolsTest;
import hxcs.tests.compiler.ProjectWriterTest;
import hxcs.tests.compiler.CsProjWriterTest;
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

		add(hxcs.tests.compilers.MsvcCompilerTest);
		add(hxcs.tests.compilers.BaseCompilersTest);
		add(hxcs.tests.compilers.MonoCompilerTest);
		add(hxcs.tests.system.SystemToolsTest);
		add(hxcs.tests.compiler.ProjectWriterTest);
		add(hxcs.tests.compiler.CsProjWriterTest);
		add(hxcs.tests.compiler.CompilerTest);
		add(hxcs.tests.compiler.PreProcessCompilerTest);
	}
}
