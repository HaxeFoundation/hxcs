package hxcs.tests.compiler;

import haxe.io.Path;
import hxcs.helpers.DataGenerator;
import proxsys.fakes.command.CommandSpecMatcher;
import proxsys.fakes.command.CommandSpec;
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
    ?hasCompilerCheck:Bool,
    ?csharpCompiler:String
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
        if (options.csharpCompiler != null){
            this.data.definesData.set("csharp-compiler", options.csharpCompiler);
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

    function givenDataWith(optData:DataOptional) {
        this.data = DataGenerator.dataWith(optData);
    }

    function givenCompiler(command:String, ?checkArgs:Array<String>, ?system:String) {
        fakeSys.givenCompiler(command, checkArgs, system);
    }

    function givenCompilers(compilers:Array<String>) {
        for(comp in compilers){
            givenCompiler(compilerWithExtension(comp));
        };
    }

    function compilerWithExtension(cmd:String, ?systemName:String) {
        if(systemName == null)
            systemName = this.fakeSys.systemName();

        var executable = Path.withoutDirectory(cmd);
        var ext = (Path.withoutExtension(executable) == "csc" ? "exe" : "bat");

        return (systemName == "Windows") ? Path.withExtension(cmd, ext) : cmd;
    }

    function shouldSelectCompiler(
        expected:String, checkArgs:Array<String>, ?options:CompilationOptions)
    {
        if(options == null) options = {};

        if(options.hasCompilerCheck != false){
            shouldUseCompilerWith(expected, checkArgs, true);
        }
        shouldUseCompilerWith(expected, (cmdSpec:CommandSpec)->{
            for (arg in checkArgs){
                if(cmdSpec.args.contains(arg)){
                    return false;
                }
            }
            return true;
        });
    }

    function shouldUseCompilerWith(
        command:String, ?args: Array<String>, ?matcher:CommandSpecMatcher, remove:Bool=false)
    {
        assertThat(executedCommandWith(command, args, matcher, remove), is(notNullValue()),
            'Should have used compiler "${command}" with: $args'
        );
    }

    function executedCommandWith(
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

        return fakeSys.executed(command, matcher, remove);
    }

    // ---------------------------------------------------

    function makeDefaultData(): Data {
        return DataGenerator.defaultData();
    }
}