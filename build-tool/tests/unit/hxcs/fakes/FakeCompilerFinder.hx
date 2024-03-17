package hxcs.fakes;

import compiler.cs.compilation.pipeline.CompilerFinder;
import compiler.cs.compilation.CompilerParameters;
import org.hamcrest.Matchers.*;


class FakeCompilerFinder implements CompilerFinder {
    public var foundCompiler:Null<String> = null;

    var findCallsCounter:Int = 0;

    public function new() {
    }

    public function findCompiler(params:CompilerParameters):Null<String> {
        ++findCallsCounter;

        return this.foundCompiler;
    }

    public function findReturns(foundCompiler:Null<String>) {
        this.foundCompiler = foundCompiler;
    }

    public function findShouldBeCalled(count:Int) {
        assertThat(findCallsCounter, equalTo(count),
            'findCompiler should have been called $count time(s)');
    }
}