package hxcs.tests.implementation;

import haxe.exceptions.NotImplementedException;
import compiler.cs.compilation.pipeline.ArgumentsGenerator;
import compiler.cs.compilation.CompilerParameters;

import haxe.Rest;

import hxcs.helpers.CompilerParametersGenerator;

import org.hamcrest.Matchers.*;


class ArgsGeneratorBaseTest {

    var argsGenerator:ArgumentsGenerator;
    var params:CompilerParameters;
	var args:Array<String>;


    public function new() {}

    @Before
    public function setup() {
        this.argsGenerator = buildArgsGenerator();
    }

    function buildArgsGenerator(): ArgumentsGenerator {
        throw new NotImplementedException("Should implement method in subclass");
    }

    // --------------------------------------------

    function test_args_generation(
        params:CompilerParameters,
        requiredArgs:()->Array<Array<String>>,
        ?shouldNotHaveArgs:()->Array<Array<String>>,
        ?pos:haxe.PosInfos)
    {
        given_parameters(params);

        when_generating_args();

        for (args in requiredArgs()){
            args_should_have(...args);
        }

        if(shouldNotHaveArgs != null){
            for (args in shouldNotHaveArgs()){
                args_should_not_have(...args);
            }
        }
    }

    function given_parameters(params:CompilerParameters) {
        this.params = CompilerParametersGenerator.parametersWith(params);

        if(this.params.name == null){
            this.params.name = 'example';
        }
    }

    function when_generating_args() {
        this.args = argsGenerator.generateArgs(params);
    }

    function args_should_have(args:Rest<String>) {
        check_has_args(true, args);
    }
    function args_should_not_have(args:Rest<String>) {
        check_has_args(false, args);
    }

    //  --------------------------------------------------------

    function check_has_args(expected:Bool, args:Array<String>) {
        // var argsArray  = args.toArray();

        var hasArgs = false;

        for (i in 0...this.args.length){
            if(containsSubsequence(this.args, i, args)){
                hasArgs = true;
                break;
            }
        }

        var should = expected? "should" : "should not";
        assertThat(hasArgs, equalTo(expected),
            'Sequence $args $should be found in generated args: ${this.args}'
        );
    }

    function containsSubsequence<T>(arr:Array<T>, fromIdx:Int, expected:Array<T>):Bool {
        var endIdx = fromIdx + expected.length - 1;
        if(endIdx >= arr.length){
            return false;
        }

        for (i in 0...expected.length){
            var srcIdx = i + fromIdx;

            if(!equalTo(expected[i]).matches(arr[srcIdx])){
                return false;
            }
        }

        return true;
    }
}