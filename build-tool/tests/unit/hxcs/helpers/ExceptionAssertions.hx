package hxcs.helpers;

import haxe.PosInfos;
import org.hamcrest.Matchers;
import org.hamcrest.Matcher;
import massive.munit.Assert;

typedef ExceptionMatcherCallable = (Dynamic, ?PosInfos)->Void;

@:callable
abstract ExceptionMatcher(ExceptionMatcherCallable)
	from ExceptionMatcherCallable to ExceptionMatcherCallable
{
	public function new(func: ExceptionMatcherCallable) {
		this = func;
	}

	@:from
	public static function fromMatcher(matcher: Matcher<Dynamic>):ExceptionMatcher {
		return new ExceptionMatcher((exc, ?posInfo)->{
			Matchers.assertThat(exc, matcher, posInfo);
		});
	}

	@:from
	public static function fromException<T>(exceptionType:Class<T>):ExceptionMatcher {
		return fromMatcher(Matchers.instanceOf(exceptionType));
	}
}

class ExceptionAssertions {
	public static function shouldThrow<T>(func:Void->T, ?matcher:ExceptionMatcher, ?pos:haxe.PosInfos) {
		var exceptionThrown = false;

		try {
			func();
		}
		catch(e:Dynamic){
			matcher(e, pos);

			exceptionThrown = true;
		}

		if(!exceptionThrown){
			Assert.fail('Did not throw any exception', pos);
		}
	}
}