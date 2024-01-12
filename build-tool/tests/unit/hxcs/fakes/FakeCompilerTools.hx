package hxcs.fakes;

import compiler.cs.system.System;
import proxsys.fakes.CommandMatcher.CommandSpec;
import proxsys.fakes.CommandMatcher.CommandSpecMatcher;
import haxe.io.Bytes;
import org.hamcrest.Matchers.*;
import haxe.io.Path;

class FakeCompilerTools {
    public static function givenCompilers(fakeSys:SystemFake, compilers:Array<String>) {
        if(compilers == null) return;

        for(comp in compilers){
            givenCompiler(fakeSys, compilerWithExtension(fakeSys, comp));
        }
    }

    public static function givenCompiler(
        fakeSys:SystemFake, command:String, ?checkArgs:Array<String>, ?system:String)
    {
        if(checkArgs == null) checkArgs = ['-help'];

        if (system == "Windows"){
            command = Path.withExtension(command, "exe");
        }

        fakeSys.givenProcess(command, checkArgs).output('').setExitCode(0);
        fakeSys.givenProcess(command).output('').setExitCode(0);
    }


    public static function
        compilerWithExtension(system:System, cmd:String, ?systemName:String)
    {
        if (cmd == null) return null;

        if(systemName == null)
            systemName = system.systemName();

        var executable = Path.withoutDirectory(cmd);
        var ext = (Path.withoutExtension(executable) == "csc" ? "exe" : "bat");

        return (systemName == "Windows") ? Path.withExtension(cmd, ext) : cmd;
    }

    // assertions --------------------------------------------------------------

    public static function
        should_have_copied(fakeSys:SystemFake, srcPath:String, dstPath:String, content:Bytes)
    {
        var out = fakeSys.getBytes(dstPath);

        assertThat(out, equalTo(content),
            '"$srcPath" should be copied to "$dstPath"');
    }

    public static function foundCompilerShouldBe(fakeSys:SystemFake, found:String, expected:String) {
        assertThat(found, is(equalTo(expected)),
            'selected compiler does not match');
    }

    public static function shouldCheckCompiler(fakeSys:SystemFake, compiler:String) {
        shouldUseCompilerWith(fakeSys, compiler, ['-help'], true);
    }

    public static function shouldUseCompilerWith(
        fakeSys:SystemFake,
        command:String, ?args: Array<String>, ?matcher:CommandSpecMatcher, remove:Bool=false)
    {
        assertThat(executedCommandWith(fakeSys, command, args, matcher, remove), is(notNullValue()),
            'Should have used compiler "${command}" with: $args'
        );
    }

    public static function executedCommandWith(
        fakeSys:SystemFake, command:String, ?args: Array<String>, ?matcher:CommandSpecMatcher, remove:Bool=false)
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
}