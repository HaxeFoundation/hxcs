package compiler.cs.compilation.preprocessing;

import input.Data;


@:structInit
class CompilerParameters{
    @:optional
    public var data(default, default):Data;

	@:optional
	public var version(default, default):Null<Int>;
	public var silverlight(default, default):Bool = false;
	public var unsafe(default, default):Bool = false;
	public var verbose(default, default):Bool = false;
	public var warn(default, default):Bool = false;
	public var debug(default, default):Bool = false;
	public var dll(default, default):Bool = false;

	@:optional
	public var name(default, default):String;
	@:optional
	public var main(default, default):String;

	@:optional
	public var libs(default, default):Array<{ name:String, hint:String }>;

	@:optional
	public var csharpCompiler(default, default):Null<String>;

	@:optional
	public var arch(default,default):Null<String>;

	@:optional
	public var output(default, default):String;

	@:optional
	public var outDir(default, default):String;

    public function clone(): CompilerParameters {
        return {
            data: data,
            version: version,
            silverlight: silverlight,
            unsafe: unsafe,
            verbose: verbose,
            warn: warn,
            debug: debug,
            dll: dll,
            name: name,
            main: main,
            libs: if(libs == null) null else libs.copy(),
            csharpCompiler: csharpCompiler,
            arch: arch,
            outDir: outDir,
            output: output
        };
    }
}