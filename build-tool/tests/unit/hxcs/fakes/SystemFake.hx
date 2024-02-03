package hxcs.fakes;

import sys.FileStat;
import haxe.io.Bytes;
import proxsys.fakes.command.CommandSpecMatcher;
import compiler.cs.system.ProcessInstance;
import proxsys.fakes.FakeFiles;
import proxsys.FakeSystem;
import compiler.cs.system.System;

using proxsys.fakes.assertions.FakeFilesAssertions;

typedef FakeFilesAssertions = proxsys.fakes.assertions.FakeFilesAssertions;


class SystemFake implements System{
    public var system:FakeSystem;

    public var files:FakeFiles;

    var sysName:String = '';

    public function new() {
        system = new FakeSystem();
        files = new FakeFiles();
    }

    public function exists(path:String):Bool {
        return files.exists(path);
    }

    public function createDirectory(path:String) {
        files.putPath(path, DirectoryType);
    }

    public function startProcess(command:String, ?args:Array<String>):ProcessInstance {
        return new ProcessAdapter(system.startProcess(command, args));
    }

    public function command(cmd:String, args:Array<String>):Int {
        return startProcess(cmd, args).exitCode();
    }

    public function systemName():String {
        return sysName;
    }

    // Given: ----------------------------------------------------

    public function givenPathIsMissing(path:String) {
        files.removePath(path);
    }

    public function givenProcess(command:String, ?args: Array<String>) {
        return system.givenProcess(command, args);
    }

    public function executed(
        command:String, ?args: Array<String>, ?matcher:CommandSpecMatcher, ?remove:Bool)
    {
        return system.getExecuted(command, args, matcher, remove);
    }

    public function defaultProcess() {
        return system.defaultProcess();
    }

    public function setSystemName(name:String) {
        this.sysName = name;
    }

    public function isDirectory(path:String):Bool {
        return this.files.isDirectory(path);
    }

    public function readDirectory(path:String):Array<String> {
        return files.readDirectory(path);
    }

    public function getBytes(path:String):Bytes {
        return this.files.getBytes(path);
    }

    public function saveBytes(path:String, bytes:Bytes) {
        this.files.saveBytes(path, bytes);
    }

    public function saveContent(path:String, content:String) {
        this.files.saveContent(path, content);
    }

    public function getCwd():String {
        return this.files.getCwd();
    }

    public function setCwd(cwd:String) {
        this.files.setCwd(cwd);
    }

    public function getEnv(envVar:String):String {
        return this.system.getEnv(envVar);
    }

    public function println(value:Dynamic)
    {}

    public function stat(path:String):FileStat {
        return this.files.stat(path);
    }
}