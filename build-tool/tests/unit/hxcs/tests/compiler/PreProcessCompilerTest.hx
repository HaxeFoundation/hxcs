package hxcs.tests.compiler;

import compiler.cs.implementation.common.ParametersParser;
import compiler.cs.compilation.CompilerParameters;
import massive.munit.Assert;
import haxe.io.Path;

import org.hamcrest.Matchers.*;

using hxcs.fakes.SystemFake.FakeFilesAssertions;
using StringTools;

class PreProcessCompilerTest extends BaseCompilerTests{

    var parametersParser:ParametersParser;

    @Before
    override public function setup() {
        super.setup();

        parametersParser = new ParametersParser(fakeSys);
    }

    @Test
    public function preprocessData() {
        var expected:CompilerParameters = {};
        expected.arch = 'x64';
        expected.csharpCompiler = 'example-compiler';
        expected.name = 'Hello';
        expected.version = 50;

        expected.debug = true;
        expected.dll = false;
        expected.silverlight = false;
        expected.unsafe = true;
        expected.verbose = false;
        expected.warn = false;

        data.main = 'some.package.${expected.name}';
        data.defines.set('NET_${expected.version}', true);

        data.definesData.set('arch', expected.arch);
        data.definesData.set('csharp-compiler', expected.csharpCompiler);

        if(expected.debug)       data.defines.set('debug', expected.debug);
        if(expected.unsafe)      data.defines.set('unsafe', expected.unsafe);
        if(expected.warn)        data.defines.set('warn', expected.warn);
        if(expected.verbose)     data.defines.set('verbose', expected.verbose);
        if(expected.dll)         data.defines.set('dll', expected.dll);
        if(expected.silverlight) data.defines.set('silverlight', expected.silverlight);

        //When:
        var params = parametersParser.parse(data, 'output');

        //Then:
        assertThat(params.data, is(equalTo(data)), 'data');

        var expectedName = if(expected.debug) '${expected.name}-Debug' else expected.name;
        assertThat(params.name, is(equalTo(expectedName)), 'name');
        assertThat(params.version, is(equalTo(expected.version)), 'version');
        assertThat(params.csharpCompiler, is(equalTo(expected.csharpCompiler)), 'csharpCompiler');
        assertThat(params.arch, is(equalTo(expected.arch)), 'arch');

        assertThat(params.debug, is(expected.debug), 'debug');
        assertThat(params.dll, is(expected.dll), 'dll');
        assertThat(params.silverlight, is(expected.silverlight), 'silverlight');
        assertThat(params.unsafe, is(expected.unsafe), 'unsafe');
        assertThat(params.verbose, is(expected.verbose), 'verbose');
        assertThat(params.warn, is(expected.warn), 'warn');
    }

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

        //When
        var params = parametersParser.parse(data, 'output');

        //Then:
        assertThat(params.libs, hasSize(expected.length));

        for (i in 0...expected.length){
            Assert.areEqual(expected[i], params.libs[i],
                'Compiler library $i should be ${expected[i]}, but was: ${params.libs[i]}');
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

        //Given: cwd
        this.fakeSys.setCwd(cwd);

        //Given: main
        data.main = main;

        //When:
        var params = parametersParser.parse(data, 'output');

        //Then:
        if(assertMessage == null)
            assertMessage = 'Compiler name should match expected value';

        assertThat(params.name, equalTo(expectedName),
            'With(cwd: $cwd, main: $main): $assertMessage');
    }
}