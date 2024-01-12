package compiler.cs.compilation.project;

import compiler.cs.compilation.preprocessing.CompilerParameters;
import compiler.cs.tools.Logger;
import haxe.io.BytesOutput;
import compiler.cs.system.System;

class ProjectGenerator implements ProjectWriter{
	var system:System;
	var logger:Logger;

	public function new(system:System, logger:Logger) {
		this.system = system;
		this.logger = logger;	
	}

	public function writeProject(params:CompilerParameters)
	{
		log('writing csproj');
		var bytes = new BytesOutput();
		new CsProjWriter(bytes).write(params);

		var projectPath = params.name + ".csproj";
		var bytes = bytes.getBytes();
		if (system.exists(projectPath))
		{
			if (system.getBytes(projectPath).compare(bytes) == 0)
				return;
		}

		system.saveBytes(projectPath, bytes);
	}

	function log(text: String, ?pos:haxe.PosInfos) {
		this.logger.log(text, pos);
	}
}