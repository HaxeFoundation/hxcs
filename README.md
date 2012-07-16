hxcs
======

Haxe C# support library. Build scripts and support code.

For now there is still only the stub implementations, but the roadmap is that until Haxe 3.0, we will have here:
 - .NET standard library externs: once they are ready and tested. Feel free to fork and provide implementations!
 - C# CFFI compatibility: be able to use unmodified .ndlls (though recompilation is needed) from hxcpp and neko in C#
 - Automatic C# build tool: The compiler already calls hxcs haxelib after building all C# files; A later version should create the .csproj file, call the C# compiler and build all files automatically.