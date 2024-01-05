package hxcs.tests.compiler;

import compiler.cs.compilation.CompilerSelector;
import compiler.cs.compilers.CsCompiler;
import hxcs.fakes.FakeCsCompiler;

import org.hamcrest.Matchers.*;
import hxcs.helpers.ExceptionAssertions.*;

class CompilerSelectorTest {

    var selector:CompilerSelector;

    var compilers:Array<FakeCsCompiler> = [];
    var found:CsCompiler;

    public function new() {}

    @Before
    public function setup() {
        selector = new CompilerSelector();
    }

    @Test
    public function select_first_found() {
        given_compilers([
            {compiler: "A", found: false},
            {compiler: "B", found:true},
            {compiler: "C", found:true}
        ]);

        find_compiler();

        compiler_should_be("B");
    }


    @Test
    public function return_null_if_not_found() {
        given_compilers([
            {compiler: "A", found: false},
            {compiler: "B", found:false},
            {compiler: "C", found:false}
        ]);

        find_compiler();

        assertThat(found, is(nullValue()),
            "Should return null if not find a compiler");
    }


    @Test
    public function require_compiler_should_throw_if_not_found() {
        given_compilers([
            {compiler: "A", found: false},
            {compiler: "B", found:false},
            {compiler: "C", found:false}
        ]);

        shouldThrow(()->this.selector.requireCompiler(compilers, null),
            equalTo(compiler.Error.CompilerNotFound));
    }

    // --------------------------------------------------------

    function given_compilers(compilers:Array<FakeCsCompiler>) {
        this.compilers = compilers;
    }

    function find_compiler() {
        found = selector.selectFrom(compilers, null);
    }

    function compiler_should_be(compilerName:String) {
        assertThat(found, is(notNullValue()), "Missing compiler");

        assertThat(found.compiler, equalTo(compilerName),
            "Found compiler name does not match the expectation");
    }

}