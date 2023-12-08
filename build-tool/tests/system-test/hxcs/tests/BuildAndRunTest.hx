package hxcs.tests;

import massive.munit.Assert;
import haxe.Exception;
import sys.io.Process;
import haxe.Rest;
import sys.FileSystem;
import haxe.io.Path;
import org.hamcrest.Matchers.*;

typedef Args = {
    ?haxe   : Array<String>,
    ?program: Array<String>
}

class BuildAndRunTest {

    var projectDir:String;
    var buildDir:String;

    public function new() {}

    @Before
    public function setup() {
        projectDir = FileSystem.absolutePath('../../..');
        buildDir = Path.join([projectDir, 'build']);
    }


    @Test
    public function simpleExample() {
        testBuildAndRunExample("Hello", "Hello World!\n");
    }

    @Test
    public function fileSystemAccess() {
        testBuildAndRunExample("Files", "Ok\n", {
            haxe: ['--lib', 'munit', '--lib', 'hamcrest'],
            program: [buildDir]
        });
    }

    function testBuildAndRunExample(example: String, expectedOutput: String, ?args:Args) {
        var main = 'hxcs.examples.${example}';
        var output = null;

        try{
            output  = buildAndRun(main, args);
        }
        catch(e){
            throw new Exception(
                'Example "$main" failed. Due to:\n\t${e}', e);
        }

        assertThat(output, equalTo(expectedOutput),
            'Output of example "$main" does not match the expected value.');
    }

    function buildAndRun(main:String, ?args: Args) {
        args = if(args == null) {} else args;

        var packageParts = main.split(".");
        var programName  = packageParts[packageParts.length - 1];

        var outDir  = transpile(main, args.haxe);
        var bin     = compile(outDir, programName);

        var programArgs = if(args.program == null) [] else args.program;

        return checkCommand(bin, programArgs);
    }

    function transpile(program:String, ?haxeArgs:Array<String>): String {
        haxeArgs = if(haxeArgs == null) [] else haxeArgs;

        var outDir = Path.join([buildDir, 'examples', program]);
        FileSystem.createDirectory(outDir);

        var args = [
            '-cs', outDir, '-D', 'no-compilation', '-cp', '.' , '--main', program, '-lib', 'hxcs'
        ].concat(haxeArgs);

        checkCommand('haxe', args,
            'Transpilation of haxe program $program failed'
        );

        return outDir;
    }

    function compile(outDir:String, program:String): String {
        // haxelib run-dir hxcs <projectDir> hxcs_build.txt --haxe-version 4302
        //     --feature-level 1 --out ../../../build/examples/example/bin/Hello

        var build_txt = Path.join([outDir, 'hxcs_build.txt']);
        var binPath   = Path.join([outDir, 'bin', program]);

        checkCommand('haxelib', ['run-dir', 'hxcs', projectDir, build_txt, '--out', binPath]);

        if(Sys.systemName() == "Windows" || !FileSystem.exists(binPath)){
            binPath += '.exe';
        }

        assertThat(FileSystem.exists(binPath), is(true),
            'Compilation failed. Program $binPath was not genereated');

        return binPath;
    }

    function runCommand(command:String, args:Rest<String>) {
        var p = runProcess(command, args.toArray());
        var output = p.stdout.readAll().toString();

        var exitCode = p.exitCode();
        assertThat(exitCode, is(0), 'Command failed: $command, ${args.toString()}');

        return output;
    }

    function checkCommand(command:String, args:Array<String>, ?errMessage:String) {
        var p = runProcess(command, args);

        var exitCode = p.exitCode();

        if(errMessage == null){
            errMessage = 'Command ${command} ${args.join(" ")} failed';
        }

        var stdout = p.stdout.readAll().toString();

        if(exitCode != 0){
            var stderr = p.stderr.readAll().toString();
            var lines = [errMessage];

            if(stdout.length > 0){
                lines.push('[stdout]: ');
                lines.push('"$stdout"');
            }
            if(stderr.length > 0){
                lines.push('[stderr]: ');
                lines.push('"$stderr"');
            }

            Assert.fail(lines.join("\n"));
        }

        return stdout;
    }

    function runProcess(command:String, args:Array<String>) {
        return new Process(command, args);
    }
}