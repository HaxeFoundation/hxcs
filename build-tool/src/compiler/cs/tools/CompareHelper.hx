package compiler.cs.tools;


class CompareHelper{
	public static function compareInt(a:Null<Int>, b:Null<Int>) {
		if(a == null || b == null)
			return compareNull(a, b);

		return a - b;
	}

	public static function compareNull<T>(a:Null<T>, b:Null<T>) {
		if(a == null && b != null) return 1;
		if(a != null && b == null) return -1;

		return 0;
	}
}