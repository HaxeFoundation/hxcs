package hxcs.fakes;

import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.compilation.CsBuilder;
import org.hamcrest.Matchers.*;


class FakeBuilder implements CsBuilder{
    var wasBuilt:Bool = false;

    var builtCommand:String = null;
    var builtArgs:Array<String> = null;
    var builtParams:Null<CompilerParameters> = null;

    public function new()
    {}

    public function build(command:String, arr:Array<String>, ?params:CompilerParameters) {
        this.wasBuilt = true;
        this.builtCommand = command;
        this.builtArgs = arr;
        this.builtParams = params;
    }

    public function projectShouldBeBuiltWith(
        compiler:String, args:Array<String>, buildParams:CompilerParameters)
    {
        assertThat(this.wasBuilt, is(true), "Project was not build");
        assertThat(this.builtCommand, is(equalTo(compiler)),
            "Build compiler does not match what was expected");
        assertThat(this.builtArgs, is(equalTo(args)),
            "Build arguments does not match what was expected");
        assertThat(this.builtParams, is(equalTo(buildParams)),
            "Build parameters does not match what expected");
    }
}