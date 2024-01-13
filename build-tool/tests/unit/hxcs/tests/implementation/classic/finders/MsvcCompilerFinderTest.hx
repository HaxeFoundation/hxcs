package hxcs.tests.implementation.classic.finders;

import compiler.cs.implementation.classic.finders.MsvcCompilerFinder;
import compiler.cs.compilation.pipeline.CompilerFinder;
import haxe.io.Path;

using hxcs.fakes.SystemFake.FakeFilesAssertions;
using hxcs.fakes.FakeCompilerTools;
using StringTools;

class MsvcCompilerFinderTest extends CompilerFinderBaseTest{

    @Before
    public override function setup() {
        super.setup();
    }

    override function makeCompilerFinder():CompilerFinder {
        return new MsvcCompilerFinder(this.fakeSys);
    }

    @Test
    public function select_compiler_default() {
        var winSys = {system: "Windows"};

        test_select_compiler('csc.exe', winSys);
        test_select_compiler('csc.exe', ['ignore_others', 'mcs', 'dmcs', 'gmcs', 'csc'], winSys);
    }

    @Test
    public function should_not_select_outside_windows() {
        var sysOpt = {system: "Other"};

        test_select_compiler(null, ['csc'], sysOpt);
    }

    @Test
    public function select_compiler_from_windir() {
        //find at windows dir
        for (winDir in [null, "D:\\other\\path"]){
            for (binVersion in ["64", ""]){
                var netVersion = "v4.8";
                var base = if(winDir == null) 'C:\\Windows' else winDir;

                var compilerPath = Path.join([
                    base, 'Microsoft.NET', 'Framework$binVersion', netVersion, 'csc.exe'
                ]);

                test_select_compiler(compilerPath, [compilerPath], {
                    env: ['windir'=> winDir],
                    paths: [compilerPath],
                    system: "Windows",
                    hasCompilerCheck: false
                });
            }
        }
    }

}