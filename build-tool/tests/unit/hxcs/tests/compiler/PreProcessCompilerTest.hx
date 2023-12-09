package hxcs.tests.compiler;

import proxsys.fakes.CommandMatcher.CommandSpec;
import massive.munit.Assert;
import org.hamcrest.Matchers;
import haxe.io.Path;

import org.hamcrest.Matchers.*;

using hxcs.fakes.SystemFake.FakeFilesAssertions;
using StringTools;

class PreProcessCompilerTest extends BaseCompilerTests{

    @Test
    public function parse_lib_references() {
        data.libs = [
            'libname',
            'nopath.dll',
            'with/path/example.dll'
        ];
        var expected = [
            {name:'libname', hint: null},
            {name:'nopath', hint: 'nopath.dll'},
            {name:'example', hint: 'with/path/example.dll'}
        ];
        var compilerCmd = 'mcs';

        givenCompiler(compilerCmd);

        //When
        compiler.compile(data);

        //Then:
        assertThat(compiler.libs, hasSize(expected.length));

        for (i in 0...expected.length){
            Assert.areEqual(expected[i], compiler.libs[i],
                'Compiler library $i should be ${expected[i]}, but was: ${compiler.libs[i]}');
        }
    }


    @Test
    public function get_project_name_from_directory() {
        var dirName = 'my-project';
        var basePath = ['a', 'b', 'c', dirName];
        var winPath  = basePath.join('\\');
        var unixPath = basePath.join('/');

        for (cwdPath in [winPath, unixPath]){
            for(cwd in [Path.removeTrailingSlashes(cwdPath),
                        Path.addTrailingSlash(cwdPath)])
            {
                test_get_project_name(cwd, null, dirName,
                    'Name should match project dir' );
            }
        }
    }

    @Test
    public function get_project_name_from_main() {
        var sysPath = Path.join(['a', 'b', 'project']);

        for(className in ['with.super.packages.Hello', 'Hello'])
        {
            test_get_project_name(sysPath, className, 'Hello',
                'Name should match main' );
            test_get_project_name(sysPath, className, 'Hello-Debug',
                'Name should match main with debug', {
                    debug:true
                });
        }
    }

    inline function test_get_project_name(
        cwd:String, main:String, expectedName:String, ?assertMessage:String, ?opt:Dynamic)
    {
        setup();

        givenOptions(opt);

        //Given: any compiler
        givenCompiler("mcs");

        //Given: cwd
        this.fakeSys.setCwd(cwd);

        //Given: main
        data.main = main;

        //When:
        compiler.compile(data);

        //Then:
        if(assertMessage == null)
            assertMessage = 'Compiler name should match expected value';

        assertThat(compiler.name, equalTo(expectedName),
            'With(cwd: $cwd, main: $main): $assertMessage');
    }
}