package hxcs.examples;

import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import massive.munit.Assert;

import org.hamcrest.Matchers.*;


class Files {
    public static function main() {
        var files = new Files();
        files.run();
    }

    var outputDir:String;

    public function new() {
    }

    public function run() {
        processArgs();

        testWriteReadDelete();

        Sys.println("Ok");
    }

    function testWriteReadDelete() {
        var txtFile = Path.join([outputDir, 'example.txt']);
        var text = 'Lorem ipsum dolor sit amet';

        File.saveContent(txtFile, text);
        var readedText = File.getContent(txtFile);

        assertThat(readedText, equalTo(text),
            'Text readed should be equal to text writed');

        FileSystem.deleteFile(txtFile);
        assertThat(FileSystem.exists(txtFile), is(false),
            'File $txtFile should not exist anymore');
    }

    function processArgs() {
        var args = Sys.args();

        if(args.length == 0){
            Sys.println('Missing argument <output dir>');
            Sys.exit(1);
        }

        outputDir = args[0];
    }
}