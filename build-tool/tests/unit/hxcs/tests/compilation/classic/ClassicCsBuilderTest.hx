package hxcs.tests.compilation.classic;

import compiler.cs.compilation.CsBuilder;
import hxcs.helpers.DataGenerator;
import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.compilation.classic.ClassicCsBuilder;
import hxcs.fakes.SystemFake;

import org.hamcrest.Matchers.*;
import hxcs.helpers.ExceptionAssertions.*;


class ClassicCsBuilderTest {
	var system:SystemFake;
	var builder:CsBuilder;
	
	var command:String;
	var args:Array<String>;
	var params:CompilerParameters;


	public function new() {}

	@Before
	public function setup() {
		system = new SystemFake();
		builder = new ClassicCsBuilder(system);
	}

	@Test
	public function build_default() {
		given_compiler_command();

		when_building();

		should_execute_with(command, args);
	}

	@Test
	public function throw_when_compiler_not_found() {
		given_compiler_command().onCall((cmd, args)->throw "AnyException");

		shouldThrow(when_building,
			equalTo(compiler.Error.CompilerNotFound)
		);
	}

	@Test
	public function should_throw_when_command_failed() {
		given_compiler_command().setExitCode(1);

		shouldThrow(
			when_building,
			equalTo(compiler.Error.BuildFailed)
		);
	}

	@Test
	public function on_windows_save_argument_to_file() {
		given_compiler_command();
		given_system("Windows");

		when_building();

		should_execute_with(command, [ClassicCsBuilder.StoredArgs]);
		should_save_content('cmd', args.join('\n'));
	}

	@Test
	public function on_windows_with_long_command_line_parameter() {
		given_compiler_command();
		given_system("Windows");
		given_parameters({
			data: DataGenerator.dataWith({
				defines: [
					'LONG_COMMAND_LINE' => true
				]
			})
		});

		when_building();

		should_execute_with(command, args);
	}

	function given_parameters(params:CompilerParameters) {
		this.params = params;
	}

	// --------------------------------------------------------------

	function should_save_content(path:String, content:String) {
		assertThat(system.files.getContent(path), equalTo(content),
			'Saved content does not match the expected');
	}

	function should_execute_with(command:String, args:Array<String>) {
		assertThat(system.executed(command, args, true), is(notNullValue()),
			'Should have executed command: "$command $args"'
		);
	}

	function given_system(sysName:String) {
		system.setSystemName(sysName);
	}


	function given_compiler_command() {
		this.command = "compiler";
		this.args = ['my', 'args'];

		return system.givenProcess(command, args);
	}

	function when_building() {
		builder.build(command, args, params);
	}
}