package hxcs.examples;

import haxe.Resource;

class EmbeddedResource {
    static function main() {
        Sys.println(Resource.getString("resource_file"));
    }
}