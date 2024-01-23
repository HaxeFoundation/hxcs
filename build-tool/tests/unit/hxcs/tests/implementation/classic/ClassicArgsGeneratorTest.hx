package hxcs.tests.implementation.classic;

import hxcs.helpers.DataGenerator;
import compiler.cs.tools.Logger;
import hxcs.fakes.SystemFake;
import compiler.cs.implementation.classic.CompilerArgsGenerator;
import compiler.cs.compilation.pipeline.ArgumentsGenerator;

class ClassicArgsGeneratorTest extends ArgsGeneratorBaseTest{
    var fakeSys:SystemFake;

    @Before
    public override function setup() {
        this.fakeSys = new SystemFake();

        super.setup();
    }

    override function buildArgsGenerator():ArgumentsGenerator {
        return new CompilerArgsGenerator(fakeSys, new Logger());
    }

    @Test
    public function add_resources() {
        var res = 'exampleResource';

        fakeSys.setSystemName('Linux');

        test_args_generation({
            name: 'example',
            data: DataGenerator.dataWith({
                resources: [res]
            })
        }, ()->[
            ['/res:src/Resources/$res,src.Resources.$res']
        ]);
    }
}