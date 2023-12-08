package compiler.cs.system;

import haxe.io.Output;
import haxe.io.Input;

interface ProcessInstance {
    public var stdout(default, null):Input;
    public var stdin(default, null):Output;

    function getPid():Int;
    function exitCode(block:Bool = true): Null<Int>;
    function kill():Void;
}