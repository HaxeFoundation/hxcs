package hxcs.tests.compilation.finders;

import haxe.PosInfos;
import compiler.cs.compilation.CompilerFinder;
import hxcs.fakes.SystemFake;
import compiler.cs.compilation.preprocessing.CompilerParameters;
import hxcs.tests.compiler.BaseCompilerTests.CompilationOptions;

import org.hamcrest.Matchers.*;

using hxcs.fakes.SystemFake.FakeFilesAssertions;
using hxcs.fakes.FakeCompilerTools;
using StringTools;

class CompilerFinderBaseTest{

    var compilerFinder:CompilerFinder;
    var compilerParams:CompilerParameters;

    var fakeSys:SystemFake;

    public function new() {
    }

    @Before
    public function setup() {
        fakeSys = new SystemFake();
        fakeSys.defaultProcess().setExitCode(-1);

        this.compilerFinder = makeCompilerFinder();
    }

    function makeCompilerFinder(): CompilerFinder {
        return null;
    }

    // -----------------------------------------------------------------------------

    function test_select_compiler(expected:String, ?existent:Array<String>, ?options:CompilationOptions, ?pos:PosInfos) {
        setup();
        requireCompilerFinder(pos);

        if(existent == null)
            existent = if(expected != null) [expected] else [];

        try {
            do_test_select_compiler(expected, existent, options);
        }
        catch(e){
            trace('Should select $expected, given compilers $existent and options: $options');
            trace(e.details());
            throw e;
        }
    }

    function requireCompilerFinder(?pos:PosInfos) {
        assertThat(compilerFinder, is(notNullValue()), "Missing required compiler finder", pos);
    }

    function do_test_select_compiler(expected:String, ?existent:Array<String>, ?options:Dynamic) {
        givenOptions(options);
        fakeSys.givenCompilers(existent);

        // When:
        var result = compilerFinder.findCompiler(compilerParams);

        // Then:
        expected = fakeSys.compilerWithExtension(expected);

        if(options.hasCompilerCheck != false && expected != null)
            fakeSys.shouldCheckCompiler(expected);

        fakeSys.foundCompilerShouldBe(result, expected);
    }

    function givenOptions(options:Null<CompilationOptions>) {
        if(options == null) options = {};

        if(options.system != null)
            this.fakeSys.setSystemName(options.system);

        compilerParams = CompilerParameters.make({
            version: options.net_version,
            silverlight: options.silverlight,
            debug: options.debug,
            verbose: options.verbose
        });
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

}