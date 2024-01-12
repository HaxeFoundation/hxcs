package hxcs.tests.compilation.finders;

import compiler.cs.compilation.finders.MonoCompilerFinder;
import compiler.cs.compilation.CompilerFinder;

using hxcs.fakes.SystemFake.FakeFilesAssertions;
using hxcs.fakes.FakeCompilerTools;
using StringTools;

class MonoCompilerFinderTest extends CompilerFinderBaseTest{

    @Before
    public override function setup() {
        super.setup();
    }

    override function makeCompilerFinder():CompilerFinder {
        return new MonoCompilerFinder(this.fakeSys);
    }

    @Test
    public function select_compiler() {
        for (system in [null, "Windows"]){
            test_select_compiler('mcs', { system: system });
            test_select_compiler('dmcs', { system: system });
            test_select_compiler('gmcs', { system: system });
            test_select_compiler('smcs', null, {
                silverlight:true,
                system: system
            });

            //precedence
            test_select_compiler('mcs', ['mcs', 'dmcs', 'gmcs'], { system: system });
            test_select_compiler('dmcs', ['dmcs', 'gmcs'], { system: system });
        }
    }

    @Test
    public function select_compiler_with_version() {
        var compilers = MonoCompilerFinder.compilers();
        var exceptMcs = compilers.copy();
        exceptMcs.remove('mcs');

        test_select_compiler('gmcs', compilers, { net_version: 20 });
        test_select_compiler('smcs', compilers, { net_version: 21, silverlight: true});
        test_select_compiler('mcs' , compilers, { net_version: 30 });
        test_select_compiler('dmcs', exceptMcs, { net_version: 40 });
        test_select_compiler(null, exceptMcs, {net_version: 50});
    }
}