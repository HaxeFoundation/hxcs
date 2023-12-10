package hxcs.helpers;

import input.Data;

class DataGenerator {
    public static function defaultData():Data {
        return {
            baseDir: '',
            opts: [],
            libs: [],
            resources: [],
            main: null,
            modules: [],
            definesData: [],
            defines: []
        };
    }
}