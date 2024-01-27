package hxcs.tests.implementation.dotnet;

import haxe.Rest;
import hxcs.fakes.SystemFake;
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

	static final sdkListExample:Array<SdkInfo> = [
		{ version: '7.0.115', path: '/usr/lib/dotnet/sdk'},
		{ version: '8.0.123', path: '/some/path'},
		{ version: '6.1.1',   path: '/other/path'}
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
}