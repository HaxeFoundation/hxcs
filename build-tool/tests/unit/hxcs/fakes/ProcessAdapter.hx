package hxcs.fakes;

import haxe.io.Output;
import haxe.io.Input;
import compiler.cs.system.ProcessInstance;


class ProcessAdapter implements ProcessInstance {
    public var stdout(default, null):Input;

    public var stdin(default, null):Output;

    var proxysProcess:proxsys.ProcessInstance;

    public function new(proxysProcess:proxsys.ProcessInstance) {
        this.proxysProcess = proxysProcess;
        this.stdout = proxysProcess.stdout;
        this.stdin = proxysProcess.stdin;
    }

    public function kill() {
        proxysProcess.kill();
    }

    public function exitCode(block:Bool = true):Null<Int> {
        return this.proxysProcess.exitCode(block);
    }

    public function getPid():Int {
        return proxysProcess.getPid();
    }
}