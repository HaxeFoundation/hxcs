package hxcs.tests.compilers;

import haxe.exceptions.NotImplementedException;
import hxcs.fakes.SystemFake;
import compiler.cs.compilers.CsCompiler;
import compiler.cs.compilation.preprocessing.CompilerParameters;
import hxcs.tests.compiler.BaseCompilerTests.CompilationOptions;

using hxcs.fakes.SystemFake.FakeFilesAssertions;
using hxcs.fakes.FakeCompilerTools;
using StringTools;

class BaseCompilersTest{

    var csCompiler:CsCompiler;
    var compilerParams:CompilerParameters;

    var fakeSys:SystemFake;

    @Before
    public function setup() {
        fakeSys = new SystemFake();
        fakeSys.defaultProcess().setExitCode(-1);

        this.csCompiler = makeCompiler();
    }

    function makeCompiler(): CsCompiler {
        throw new NotImplementedException('Needs to override makeCompiler function');
    }

    // -----------------------------------------------------------------------------

    function test_select_compiler(expected:String, ?existent:Array<String>, ?options:CompilationOptions) {
        setup();
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
    function do_test_select_compiler(expected:String, ?existent:Array<String>, ?options:Dynamic) {
        givenOptions(options);
        fakeSys.givenCompilers(existent);

        // When:
        var result = csCompiler.findCompiler(compilerParams);

        // Then:
        expected = fakeSys.compilerWithExtension(expected);

        if(options.hasCompilerCheck != false && expected != null)
            fakeSys.shouldCheckCompiler(expected);

        result.shouldHaveFoundCompiler(expected != null);

        fakeSys.foundCompilerShouldBe(csCompiler.compiler, expected);
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