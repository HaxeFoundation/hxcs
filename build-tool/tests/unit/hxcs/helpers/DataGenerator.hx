package hxcs.helpers;

import input.Data;

typedef DataOptional = {
	?baseDir:String,
	?defines:Map<String, Bool>,
	?definesData:Map<String, String>,
	?modules:Array<{ path:String, types:Array<ModuleType> }>,
	?main:Null<String>,
	?resources:Array<String>,
	?libs:Array<String>,
	?opts:Array<String>
};

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

	public static function dataWith(optData:DataOptional) {
		var data = defaultData();

		for(field in Reflect.fields(optData)){
			if(Reflect.hasField(data, field)){
				var value = Reflect.field(optData, field);

				Reflect.setField(data, field, value);
			}
		}

		return data;
	}
}