package hxcs.tests.compilers;

import compiler.cs.compilers.CsCompiler;
import haxe.io.Path;
import compiler.cs.compilers.MsvcCompiler;

using hxcs.fakes.SystemFake.FakeFilesAssertions;
using hxcs.fakes.FakeCompilerTools;
using StringTools;

class MsvcCompilerTest extends BaseCompilersTest{

    @Before
    public override function setup() {
        super.setup();
    }

    override function makeCompiler():CsCompiler {
        return new MsvcCompiler(this.fakeSys);
    }

    
    @Test
    public function select_compiler_default() {
        var winSys = {system: "Windows"};

        test_select_compiler('csc.exe', winSys);
        test_select_compiler('csc.exe', ['ignore_others', 'mcs', 'dmcs', 'gmcs', 'csc'], winSys);
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