package hxcs.helpers;

import compiler.cs.compilation.CompilerParameters;

class CompilerParametersGenerator {
    public static function parametersWith(params:CompilerParameters) {
        var p = defaultParameters();

        for(field in Type.getInstanceFields(CompilerParameters)){
            var value = Reflect.field(params, field);
            if(value != null){
                Reflect.setField(p, field, value);
            }
        }

        return p;
    }

    public static function defaultParameters(): CompilerParameters {
        var params = CompilerParameters.make({
            data: DataGenerator.defaultData(),
            libs: []
        });

        return params;
    }
}