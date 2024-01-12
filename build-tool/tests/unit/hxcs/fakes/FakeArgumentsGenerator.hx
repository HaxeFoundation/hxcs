package hxcs.fakes;

import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.compilation.ArgumentsGenerator;
import org.hamcrest.Matchers.*;


class FakeArgumentsGenerator implements ArgumentsGenerator{
    var hasGenerated:Bool = false;
    var receivedParams:Null<CompilerParameters> = null;

    public var returnedArgs:Array<String>;

    public function new() {
        this.returnedArgs = ["lorem", "ipsum"];
    }

    public function generateArgs(params:CompilerParameters):Array<String> {
        hasGenerated = true;
        receivedParams = params;

        return this.returnedArgs;
    }

    public function assertGeneratedArgsWith(params:CompilerParameters) {
        assertThat(this.hasGenerated, is(true), "Arguments was not generated");
        assertThat(this.receivedParams, is(equalTo(params)),
            "Received parameters does not match what expected");
    }
}