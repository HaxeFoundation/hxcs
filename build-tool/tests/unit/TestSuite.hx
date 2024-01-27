import massive.munit.TestSuite;

import hxcs.tests.system.SystemToolsTest;
import hxcs.tests.implementation.CompilerFinderBaseTest;
import hxcs.tests.implementation.dotnet.DotnetEnablerTest;
import hxcs.tests.implementation.dotnet.DotnetArgsGeneratorTest;
import hxcs.tests.implementation.dotnet.DotnetSdkConfiguratorTest;
import hxcs.tests.implementation.dotnet.DotnetFinderTest;
import hxcs.tests.implementation.common.CsProjWriterTest;
import hxcs.tests.implementation.common.DefaultCsBuilderTest;
import hxcs.tests.implementation.classic.ClassicArgsGeneratorTest;
import hxcs.tests.implementation.classic.finders.MsvcCompilerFinderTest;
import hxcs.tests.implementation.classic.finders.MonoCompilerFinderTest;
import hxcs.tests.implementation.ArgsGeneratorBaseTest;
import hxcs.tests.compiler.DotnetCoreCompilerTest;
import hxcs.tests.compiler.ProjectWriterTest;
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
		add(hxcs.tests.implementation.CompilerFinderBaseTest);
		add(hxcs.tests.implementation.dotnet.DotnetEnablerTest);
		add(hxcs.tests.implementation.dotnet.DotnetArgsGeneratorTest);
		add(hxcs.tests.implementation.dotnet.DotnetSdkConfiguratorTest);
		add(hxcs.tests.implementation.dotnet.DotnetFinderTest);
		add(hxcs.tests.implementation.common.CsProjWriterTest);
		add(hxcs.tests.implementation.common.DefaultCsBuilderTest);
		add(hxcs.tests.implementation.classic.ClassicArgsGeneratorTest);
		add(hxcs.tests.implementation.classic.finders.MsvcCompilerFinderTest);
		add(hxcs.tests.implementation.classic.finders.MonoCompilerFinderTest);
		add(hxcs.tests.implementation.ArgsGeneratorBaseTest);
		add(hxcs.tests.compiler.DotnetCoreCompilerTest);
		add(hxcs.tests.compiler.ProjectWriterTest);
		add(hxcs.tests.compiler.CompilerTest);
		add(hxcs.tests.compiler.PreProcessCompilerTest);
		add(hxcs.tests.compilation.CompilerPipelineTest);
		add(hxcs.tests.compilation.CompilerSelectorTest);
	}
}
