package hxcs.tests.implementation.dotnet;

import compiler.cs.implementation.dotnet.DotnetArgsGenerator;
import hxcs.helpers.DataGenerator;
import compiler.cs.compilation.pipeline.ArgumentsGenerator;

import haxe.io.Path;

using compiler.cs.tools.ParametersTools;


class DotnetArgsGeneratorTest extends ArgsGeneratorBaseTest {

    override function buildArgsGenerator():ArgumentsGenerator {
        return new DotnetArgsGenerator();
    }

    @Test
    public function minimal_build() {
        test_args_generation({
            name: 'example',
            outDir: null
        }, ()->[
            ['build', 'example.csproj']
        ], ()->[
            ['-o']
        ]);
    }

    @Test
    public function build_with_output_dir() {
        test_args_generation({
            name: 'example',
            outDir: Path.join(['example', 'path', 'bin'])
        }, ()->[
            ['build', params.csProj()],
            ['-o', params.outDir]
        ]);
    }

    @Test
    public function build_for_architecture() {
        test_args_generation({
            name: 'example',
            arch: 'x86'
        }, ()->[
            ['--arch', params.arch]
        ]);
    }

    @Test
    public function specify_main() {
        // -p:StartupObject=foo.Program2  (https://stackoverflow.com/questions/43365254/dotnet-build-specify-main-method)

        final entryPoint = 'EntryPoint__Main';

        for (main => mainClass in [
            'mynamespace.example.Hello' => ()->params.main,
            'Main' => ()-> entryPoint,
            'namespace.Main' => ()->'namespace.$entryPoint'
        ]){
            test_args_generation({
                name: 'example',
                dll: false,
                main: main
            }, ()->[
                ['-p:StartupObject=${mainClass()}']
            ]);
        }
    }

    @Test
    public function generate_debug_info() {
        test_args_generation({
            debug: true
        }, ()->[
            ['--debug'],
            ['-p:Optimize=false']
        ]);
    }

    @Test
    public function no_debug_info() {
        test_args_generation({
            debug: false
        }, ()->[
            ['-p:Optimize=true']
        ], ()->[
            ['--debug']
        ]);
    }

    @Test
    public function specify_warning_level() {
        for(level=>warn in [1 => true, 0 => false]){
            test_args_generation({
                warn: warn
            }, ()->[
                ['-p:WarningLevel=$level']
            ]);
        }
    }

    @Test
    public function specify_output_type() {
        for(outputType=>isLibrary in ['Library' => true, 'Exe' => false]){
            test_args_generation({
                dll: isLibrary
            }, ()->[
                ['-p:OutputType=$outputType']
            ]);
        }
    }

    @Test
    public function allow_unsafe_blocks() {
        for(opt=>unsafe in ['true' => true, 'false' => false]){
            test_args_generation({
                unsafe: unsafe
            }, ()->[
                ['-p:AllowUnsafeBlocks=$opt']
            ]);
        }
    }

    @Test
    public function test_extra_options() {
        test_args_generation({
            data: DataGenerator.dataWith({
                opts: ['extra', 'options']
            })
        }, ()->[
            params.data.opts
        ]);
    }

    // ---------------------------------------------------------------------

}