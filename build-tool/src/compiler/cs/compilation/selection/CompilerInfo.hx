package compiler.cs.compilation.selection;

@:structInit
class CompilerInfo{
	@:optional
	public var path(default, default): String;

	@:optional
	public var compiler(default, default): String;

	@:optional
	public var command(default, default):String;
}