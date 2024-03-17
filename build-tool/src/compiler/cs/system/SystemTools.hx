package compiler.cs.system;

import haxe.io.Path;

using StringTools;


class SystemTools {
    public static function addBasePath(path: String, basePath: String): String {
        if(Path.isAbsolute(path) || path.startsWith('\\')){
            return path;
        }

        return Path.join([basePath, path]);
    }

    public static function copy(system:System, srcPath: String, dstPath: String) {
		return system.saveBytes(dstPath, system.getBytes(srcPath));
    }

    public static function copyIfNewer(system:System, srcPath: String, dstPath: String) {
        if(!system.exists(dstPath) || isNewer(system, srcPath, dstPath)){
            copy(system, srcPath, dstPath);
        }
    }

    public static function isNewer(system:System, srcPath:String, dstPath:String) {
        var srcStat = system.stat(srcPath);
        var dstStat = system.stat(dstPath);

        return srcStat.mtime.getTime() > dstStat.mtime.getTime();
    }

    public static function copyTreeNewer(system:System, from:String, to:String){
        if (system.isDirectory(from))
        {
            if (!system.exists(to))
            {
                system.createDirectory(to);
            }

            for (file in system.readDirectory(from))
            {
                copyTreeNewer(system, Path.join([from, file]), Path.join([to, file]));
            }
        } else {
            copyIfNewer(system, from, to);
        }
    }
}