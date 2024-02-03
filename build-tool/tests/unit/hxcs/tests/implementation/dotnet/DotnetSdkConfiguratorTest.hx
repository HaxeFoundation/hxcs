package hxcs.tests.implementation.dotnet;

import haxe.exceptions.ArgumentException;
import hxcs.helpers.DataGenerator;
import hxcs.fakes.SystemFake;
import compiler.cs.implementation.dotnet.DotnetDefines;
import compiler.cs.implementation.dotnet.DotnetSdkConfigurator;
import compiler.cs.compilation.CompilerParameters;
import hxcs.helpers.CompilerParametersGenerator;

import org.hamcrest.Matchers.*;


class DotnetSdkConfiguratorTest {
	var fakeSys:SystemFake;
	var sdkConfigurator:DotnetSdkConfigurator;

	public function new() {
	}

	@Before
	public function setup() {
		fakeSys = new SystemFake();
		sdkConfigurator = new DotnetSdkConfigurator(fakeSys);
	}

	static final SDK_EXAMPLE_6_0:SdkInfo =
		{ version: '6.0.1',   path: '/other/path'};
	static final SDK_EXAMPLE_7_0:SdkInfo =
		{ version: '7.0.115', path: '/usr/lib/dotnet/sdk'};
	static final SDK_EXAMPLE_8_0:SdkInfo =
		{ version: '8.0.123', path: '/some/path'};

	static final sdkListExample:Array<SdkInfo> = [
		SDK_EXAMPLE_7_0,
		SDK_EXAMPLE_8_0,
		SDK_EXAMPLE_6_0
	];

	@Test
	public function configure_dotnet_version() {
		given_sdks(sdkListExample);

		var params = when_configuring_params(
			CompilerParametersGenerator.defaultParameters());

		assertThat(params.version, equalTo(80),
			"Should configure sdk version with the greatest available sdk");
	}

	@Test
	public function list_sdks() {
		given_sdks(sdkListExample);

		var sdksText = sdkConfigurator.listSdks();

		assertThat(sdksText, equalTo(formatSdks(sdkListExample)));
	}

	@Test
	public function parse_sdks() {
		// Given
		var expectedSdks:Array<SdkInfo> = sdkListExample.copy();
		var sdksText = formatSdks(expectedSdks);

		//When
		var sdks = sdkConfigurator.parseSdks(sdksText);

		// Then
		assertThat(sdks, is(array(expectedSdks)),
			'Parsed sdks does not match the expectation');
	}

	@Test
	public function parse_sdks_ignore_empty_lines() {
		var expectedSdks = [
			new SdkInfo('1.2.3', '/path/example'),
			new SdkInfo('3.2.1', '/other/path')
		];
		var parsedSdks = sdkConfigurator.parseSdks('
${expectedSdks[0].toString()}

${expectedSdks[1].toString()}

		');

		assertThat(parsedSdks, is(array(expectedSdks)));
	}

	@Test
	public function choiceSdks() {
		// Given
		var expectedSdk = sdkListExample[1];

		//When
		var version = sdkConfigurator.choiceSdkVersion(sdkListExample);

		// Then
		assertThat(version, equalTo(expectedSdk.version),
			'Version does not match');
	}

	@Test
	public function choiceSpecifiedSdk() {
		// Given
		var expectedVersion = choiceOne([SDK_EXAMPLE_6_0, SDK_EXAMPLE_7_0]).version;
		var versionText = '${expectedVersion.major}.${expectedVersion.minor}';

		var params = CompilerParametersGenerator.parametersWith({
			data: DataGenerator.dataWith({
				definesData: [
					DotnetDefines.Enabler => versionText
				]
			})
		});

		// When:
		var foundVersion = sdkConfigurator.choiceSdkVersion(sdkListExample, params);

		// Then:
		assertThat(foundVersion, equalTo(expectedVersion),
			'Choosen version does not match expected version');
	}

	@Test
	public function version_matches() {
		var params = [
			{ version: '6.0.123', matches: '6', expected: true},
			{ version: '6.0.123', matches: '6.0', expected: true},
			{ version: '6.0.123', matches: '6.0.123', expected: true},
			{ version: '6.0.123', matches: '7', expected: false},
			{ version: '6.0.123', matches: '7.0.123', expected: false},
			{ version: '6.0.123', matches: '6.1', expected: false},
			{ version: '6.0.123', matches: '6.1.123', expected: false},
			{ version: '6.0.123', matches: '6.0.124', expected: false},
			{ version: '6.0.123', matches: '6.0.1234', expected: false},
			{ version: '6.0.123', matches: '6.0.1', expected: false},
		];

		for(param in params){
			test_version_matches(param.version, param.matches, param.expected);
		}
	}

	function test_version_matches(v_text:String, matches:String, expected:Bool) {
		var version = new VersionInfo(v_text);

		var result = version.matches(matches);

		var should = expected ? 'should' : 'should not';
		assertThat(result, equalTo(expected),
			'Version $v_text $should match $matches');
	}

	@Test
	public function updateParametersVersion() {
		//Given
		var version = new VersionInfo('6.2.3');
		var params = CompilerParametersGenerator.parametersWith({
			version: 20
		});

		// When
		var newParams = sdkConfigurator.updateDotnetVersion(params, version);

		// Then
		assertThat(newParams, is(notNullValue()));
		assertThat(newParams.version, equalTo(version.major * 10),
			'Version does not match');
	}

	// ---------------------------------------

	function given_sdks(sdks:Array<SdkInfo>) {
		fakeSys.givenProcess('dotnet', ['--list-sdks']).output(
			formatSdks(sdks)
		);
	}

	function formatSdks(sdks:Array<SdkInfo>) {
		return [for(sdk in sdks) sdk.toString()].join('\n');
	}

	function when_configuring_params(params:CompilerParameters) : CompilerParameters{
		return sdkConfigurator.configure(params);
	}


	function choiceOne<T>(items:Array<T>): T {
		if(items.length == 0)
			throw new ArgumentException('items',
				'Invalid argument items: should be a non empty array');

		var index = Std.random(items.length);

		return items[index];
	}
}