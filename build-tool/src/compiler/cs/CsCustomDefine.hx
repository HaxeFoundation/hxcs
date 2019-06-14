package compiler.cs;

@:enum abstract CsCustomDefine(String) to String {
	/**
		If set, output assembly as a library dll.
	**/
	var Dll = 'dll';

	/**
		Specifies the target platform of the output assembly ARCH can be one of:
		'anycpu', 'anycpu32bitpreferred', 'arm', 'x86', 'x64' or 'itanium'.

		If not defined, defaults to 'anycpu'.
	**/
	var Arch = 'arch';

	/**
		Sets warning level (0-4).
		The default is 0, or 1 if the define is set with no value.
	**/
	var Warn = 'warn';

	/**
		Specify the C# compiler to use (mcs, dmcs, smcs, gmcs, etc.).
	**/
	var CSharpCompiler = 'csharp-compiler';

	/**
		If set, will consider smcs as a potential C# compiler.
	**/
	var Silverlight = 'silverlight';

	/**
		Windows only.

		If not defined, will generate a file containing the build arguments and
		use it to pass arguments to the C# compiler.
	**/
	var LongCommandLine = 'LONG_COMMAND_LINE';

	public function withNamespace():String return 'hxcs.$this';
}

