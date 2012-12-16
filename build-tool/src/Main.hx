package ;

import haxe.io.Path;
import input.Reader;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

/**
 * Java build tool. For now there is only a stub implementation, but
 * an automatic java build tool is intended to be supported.
 * @author waneck
 */

class Main 
{
	
	static function main() 
	{
		var target = null;
		try
		{
			//pre-process args:
			var cmd = new CommandLine(#if target_cs "hxcs" #else "hxjava" #end);
			var args = Sys.args();
			var last = args[args.length - 1];
			
			var cwd = Sys.getCwd();
			if (last != null && FileSystem.exists(last = last.substr(0,last.length-1))) //was called from haxelib
			{
				args.pop();
				Sys.setCwd(cwd = last);
			}
			
			//get options
			cmd.process(args);
			if (cmd.target == null)
				throw Error.NoTarget;
			
			//read input
			if (!FileSystem.exists(target = cmd.target))
				throw Error.InexistentInput(target);
			var f = File.read(target);
			var data = new Reader(f).read();
			f.close();
			
			data.baseDir = Tools.addPath(cwd, data.baseDir);
			Sys.setCwd(Path.directory(Tools.addPath(cwd, cmd.target)));
			
			//compile
			#if !target_cs
			new compiler.java.Javac(cmd).compile(data);
			#else
			new compiler.cs.CSharpCompiler(cmd).compile(data);
			#end
		}
		
		catch (e:Error)
		{
			switch(e)
			{
			case UnknownOption(name):
				Sys.println("Unknown command-line option " + name);
			case BadFormat(optionName, option):
				Sys.println("Unrecognized '" + option + "' value for " + optionName);
			case InexistentInput(path):
				Sys.println("File at path " + path + " not found");
			case NoTarget:
				Sys.println("No target defined");
			}
			
			Sys.println(new CommandLine(#if target_cs "hxcs" #else "hxjava" #end).getOptions());
			
			Sys.exit(1);
		}
		
		catch (e:input.Error)
		{
			Sys.println("Error when reading input file");
			switch(e)
			{
			case UnmatchedSection(name, expected, lineNum):
				Sys.println(target + " : line " + lineNum + " : Unmatched end section. Expected " + expected + ", got " + name);
			case Unexpected(string, lineNum):
				Sys.println(target + " : line " + lineNum + " : Unexpected " + string);
			}
			Sys.exit(2);
		}
		
		catch (e:compiler.Error)
		{
			Sys.println("Compilation error");
			switch(e)
			{
			case CompilerNotFound:
				#if target_java
				Sys.println("Java compiler not found. Please make sure JDK is installed. If it is, please add an environment variable called JAVA_HOME that points to the JDK install location or add the bin subfolder to your PATH environment.");
				#elseif target_cs
				Sys.println("C# compiler not found. Please make sure either Visual Studio or mono is installed or they are reachable by their path");
				#else
				Sys.println("Native compiler not found. Please make sure it is installed and its path is set correctly");
				#end
			case BuildFailed:
				Sys.println("Native compilation failed");
			}
			Sys.exit(3);
		}
		
	}
}