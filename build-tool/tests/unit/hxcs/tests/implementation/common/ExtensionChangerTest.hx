package hxcs.tests.implementation.common;

import haxe.io.Path;
import hxcs.helpers.CompilerParametersGenerator;
import hxcs.fakes.SystemFake;
import compiler.cs.compilation.CompilerDefines;
import compiler.cs.implementation.common.ExtensionChanger;

import org.hamcrest.Matchers.*;


class ExtensionChangerTest {
    var extensionChanger:ExtensionChanger;

    var system:SystemFake;


    public function new() {}

    @Before
    public function setup() {
        system = new SystemFake();

        extensionChanger = new ExtensionChanger(system);
    }

    @Test
    public function changeExtension() {
        var newExt = 'newExt';
        var params = CompilerParametersGenerator.parametersWithData({
            definesData: [
                CompilerDefines.OutputExtension => newExt
            ]
        });
        params.output = "out.exe";
        system.givenFile(params.output);

        // When:
        extensionChanger.apply(params);

        // Then:
        var expectedPath = Path.withExtension(params.output, newExt);
        assertThat(system.exists(expectedPath), is(true),
            'Path ${params.output} should be renamed to $expectedPath');
    }
}