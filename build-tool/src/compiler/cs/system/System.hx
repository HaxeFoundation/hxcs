package compiler.cs.system;

import haxe.io.Bytes;
import sys.io.File;
import sys.FileSystem;

interface System {
    function exists(path:String): Bool;
    function createDirectory(path:String): Void;
    function readDirectory(path:String): Array<String>;

    function getBytes(path:String):Bytes;
    function saveBytes(path:String, bytes:Bytes):Void;
    function saveContent(path:String, content:String):Void;

    function startProcess(command:String, ?args:Array<String>): ProcessInstance;
    function command(command:String, args:Array<String>): Int;

    function systemName():  String;
    function getCwd(): String;
    function getEnv(envVar:String): String;
    function println(value:Dynamic):Void;
}