package compiler.cs.system;

import sys.FileStat;
import haxe.io.Bytes;
import sys.io.File;
import sys.FileSystem;

class StdSystem implements System{
    public function new()
    {}

    public function exists(path:String):Bool {
        return FileSystem.exists(path);
    }

    public function createDirectory(path:String) {
        FileSystem.createDirectory(path);
    }

    public function rename(srcPath:String, newPath:String):Void{
        FileSystem.rename(srcPath, newPath);
    }

    public function startProcess(command:String, ?args:Array<String>) {
        return new SysProcess(command, args);
    }

    public function command(command:String, args:Array<String>): Int {
        return Sys.command(command, args);
    }

    public function systemName() {
        return Sys.systemName();
    }

    public function getBytes(path:String) {
        return File.getBytes(path);
    }

    public function saveBytes(path:String, bytes:Bytes) {
        File.saveBytes(path, bytes);
    }

    public function saveContent(path:String, content:String) {
        File.saveContent(path, content);
    }

    public function isDirectory(path:String):Bool {
        return FileSystem.isDirectory(path);
    }

    public function readDirectory(path:String): Array<String> {
        return FileSystem.readDirectory(path);
    }

    public function getEnv(envVar:String): String {
        return Sys.getEnv(envVar);
    }

    public function getCwd(): String {
        return Sys.getCwd();
    }

    public function println(value:Dynamic) {
        Sys.println(value);
    }

    public function stat(path:String):FileStat {
        return FileSystem.stat(path);
    }
}