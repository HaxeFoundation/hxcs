package compiler.cs.tools;

class Logger {
	public var verbose(default, default):Bool = false;

	public function new()
	{}

	public function log(str:String,?pos:haxe.PosInfos)
	{
		if (this.verbose) haxe.Log.trace(str,pos);
	}
}