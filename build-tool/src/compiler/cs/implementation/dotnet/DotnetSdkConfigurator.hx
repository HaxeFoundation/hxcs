package compiler.cs.implementation.dotnet;

import compiler.cs.tools.Logger;
import haxe.exceptions.ArgumentException;
import haxe.Exception;
import compiler.cs.system.System;
import compiler.cs.compilation.CompilerParameters;
import compiler.cs.compilation.pipeline.EnvironmentConfigurator;

import compiler.cs.tools.CompareHelper.*;

using StringTools;

class DotnetSdkConfigurator implements EnvironmentConfigurator{
	var system:System;
	var logger:Logger;

	public function new(system:System, ?logger:Logger) {
		this.system = system;
		this.logger = logger;
	}

	public function configure(params:CompilerParameters):CompilerParameters {
		var sdksText = listSdks();

		log('list sdks output: $sdksText');

		var sdks = parseSdks(sdksText);
		var sdkVersion = choiceSdkVersion(sdks);

		return updateDotnetVersion(params, sdkVersion);
	}

	function log(text:String, ?pos:haxe.PosInfos) {
		if(logger != null)
			logger.log(text, pos);
	}

	public function listSdks(): String {
		var proc =  system.startProcess('dotnet', ['--list-sdks']);
		var exitCode = proc.exitCode();
		if(exitCode != 0){
			log('dotnet list-sdks failed');
		}

		return proc.stdout.readAll().toString();
	}

	public function parseSdks(sdksText:String): Array<SdkInfo> {
		var lines = sdksText.split('\n');
		lines = [for(l in lines) l.trim()];

		return [
			for(l in lines)
				if(l.length > 0) parseSdk(l.trim())
		];
	}

	public function parseSdk(sdkLine:String):SdkInfo {
		log('parsing sdk line: $sdkLine');

		var versionPattern = '(([0-9]+)(\\.[0-9]+)*(-[0-9a-zA-Z])?)';
		var pathPattern = '\\[([\\/0-9a-zA-Z]+)\\]';
		var sdkPattern = '$versionPattern' + '\\s+' + pathPattern;

		var reg = new EReg(sdkPattern, '');

		if(reg.match(sdkLine)){
			return new SdkInfo(
				reg.matched(1),
				reg.matched(5)
			);
		}

		throw new ParseException(
			'Sdk info could not be parsed from text: "$sdkLine"');
	}

	public function choiceSdkVersion(sdks:Array<SdkInfo>): VersionInfo {
		if(sdks == null || sdks.length == 0)
			throw new NotFoundSdk();

		var sorted = sdks.copy();
		sorted.sort((a, b)-> {
			//Invert compare to get descending order
			return -1 * SdkInfo.compare(a, b);
		});

		return sorted[0].version;
	}

	public function updateDotnetVersion(params:CompilerParameters, sdkVersion:VersionInfo): CompilerParameters {
		if(sdkVersion == null || sdkVersion.major == null)
			throw new ArgumentException('$sdkVersion', "Invalid sdk version");

		var clone = params.clone();
		clone.version = sdkVersion.major * 10;

		return clone;
	}
}

class ParseException extends Exception
{}

class NotFoundSdk extends Exception {
	public function new(?message:String, ?previous:Exception, ?native:Any){
		if(message == null)
			message = "Not found valid .NET SDK";

		super(message, previous, native);
	}
}

@:structInit
class SdkInfo {
	public var version(default, default):VersionInfo;
	public var path(default, default):String;

	public function new(version:String, path:String) {
		this.version = new VersionInfo(version);
		this.path = path;
	}

	public function toString() {
		return '${version} [$path]';
	}

	public function equals(other:SdkInfo) {
		if(other == null) return false;

		return this.path == other.path
			&& VersionInfo.areEquals(this.version, other.version);
	}

	public static function compare(a:SdkInfo, b:SdkInfo): Int {
		var cmp = compareNull(a, b);

		if(cmp == 0) cmp = VersionInfo.compare(a.version, b.version);

		return cmp;
	}
}

class VersionInfo {
	public var version(default, null):String;
	public var major(default, null):Null<Int> = null;
	public var minor(default, null):Null<Int> = null;
	public var patch(default, null):Null<Int> = null;

	public function new(version:String) {
		this.version = version;

		var versionRegex = ~/(\d+)(.(\d+)(.(\d+))?)?/;
		if(versionRegex.match(version)){
			this.major = Std.parseInt(versionRegex.matched(1));
			this.minor = Std.parseInt(versionRegex.matched(3));
			this.patch = Std.parseInt(versionRegex.matched(5));
		}
	}

	public function toString():String {
		return this.version;
	}

	public static function areEquals(v1:VersionInfo, v2:VersionInfo) {
		if(v1 == v2) return true;
		if(v1 == null || v2 == null) return v1 == v2;

		return v1.equals(v2);
	}

	public function equals(other:VersionInfo) {
		if(other == null) return false;

		return Reflect.compare(this.version, other.version) == 0;
	}

	public static function compare(v1:VersionInfo, v2:VersionInfo) {
		if(v1 == null){
			return compareNull(v1, v2);
		}

		return v1.compareWith(v2);
	}

	public function compareWith(other:VersionInfo) {
		if(other == null) return 1;

		var cmp = compareInt(major, other.major);

		if(cmp == 0) cmp = compareInt(minor, other.minor);
		if(cmp == 0) cmp = compareInt(patch, other.patch);
		if(cmp == 0) cmp = Reflect.compare(version, other.version);

		return cmp;
	}
}
