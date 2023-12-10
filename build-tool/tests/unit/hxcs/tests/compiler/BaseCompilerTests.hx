package hxcs.tests.compiler;

import hxcs.helpers.DataGenerator;
import proxsys.fakes.CommandMatcher.CommandSpecMatcher;
import proxsys.fakes.CommandMatcher.CommandSpec;
import input.Data;
import hxcs.fakes.CommandLineFake;
import hxcs.fakes.SystemFake;
import compiler.cs.CSharpCompiler;

import org.hamcrest.Matchers.*;

using hxcs.fakes.SystemFake.FakeFilesAssertions;
using hxcs.fakes.FakeCompilerTools;
using StringTools;

typedef CompilationOptions = {
    ?net_version: Int,
    ?silverlight: Bool,
    ?debug:Bool,
    ?system:String,
    ?verbose:Bool,
    ?env: Map<String, Null<String>>,
    ?paths: Iterable<String>,
    ?hasCompilerCheck:Bool
};

class BaseCompilerTests {

    var fakeSys:SystemFake;
    var fakeCmd:CommandLineFake;
    var compiler:CSharpCompiler;

    var data:Data;

    public function new() {
    }

    @Before
    public function setup() {
        fakeSys = new SystemFake();
        fakeCmd = new CommandLineFake();
        compiler = new CSharpCompiler(fakeCmd, fakeSys);
        data = makeDefaultData();

        fakeSys.defaultProcess().setExitCode(-1);
    }

    function givenOptions(options:Null<CompilationOptions>) {
        if(options == null) return;

        if(options.net_version != null)
            this.data.defines.set('NET_${options.net_version}', true);
        if(options.silverlight == true)
            this.data.defines.set('silverlight', true);
        if(options.debug == true)
            this.data.defines.set("debug", true);
        if(options.system != null)
            this.fakeSys.setSystemName(options.system);
        if(options.verbose == true){
            this.data.defines.set("verbose", true);
        }
        if(options.paths != null){
            for(p in options.paths){
                this.fakeSys.files.putPath(p, FileType);
            }
        }
        if(options.env != null){
            for(env_var => env_value in options.env.keyValueIterator()){
                this.fakeSys.system.putEnv(env_var, env_value);
            }
        }
    }

    function givenCompiler(command:String, ?checkArgs:Array<String>, ?system:String) {
        fakeSys.givenCompiler(command, checkArgs, system);
    }

    function shouldUseCompilerWith(
        command:String, ?args: Array<String>, ?matcher:CommandSpecMatcher, remove:Bool=false)
    {
        if(matcher == null){
            matcher = (cmdSpec:CommandSpec)->{
                for(a in args){
                    if(!cmdSpec.args.contains(a)){
                        return false;
                    }
                }
                return true;
            };
        }

        assertThat(fakeSys.executed(command, matcher, remove), is(notNullValue()),
            'Should have used compiler "${command}" with: $args'
        );
    }

    // ---------------------------------------------------

    function makeDefaultData(): Data {
        return DataGenerator.defaultData();
    }
}