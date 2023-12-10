package hxcs.fakes;

import haxe.io.Path;

class FakeCompilerTools {
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
}