package hxcs.tests.compiler;

import haxe.io.Bytes;

import org.hamcrest.Matchers.*;

using hxcs.fakes.SystemFake.FakeFilesAssertions;
using StringTools;

class ProjectWriterTest extends BaseCompilerTests{

    @Test
    public function should_write_project_if_does_not_exist() {
        test_write_project(null);
    }

    @Test
    public function should_rewrite_project_if_modified() {
        test_write_project(Bytes.ofString('<?xml version="1.0" encoding="utf-8"?>
        <Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
        </Project>'));
    }

    function test_write_project(?currentProject:Bytes) {
        //Given: any compiler
        givenCompiler("mcs");

        //Given: projectName from main
        var projectName = "Hello";
        data.main = projectName;

        //Given: project path
        var projectPath = projectName + ".csproj";
        if(currentProject != null){
            fakeSys.saveBytes(projectPath, currentProject);
        }
        else{
            fakeSys.givenPathIsMissing(projectPath);
        }

        //When:
        compiler.compile(data);

        //Then: create file
        fakeSys.files.pathShouldExist(projectPath);

        //And: should have a new content
        var createdProj = fakeSys.files.getBytes(projectPath).toString();

        assertThat(createdProj, is(notNullValue()), 'Project has content');
        assertThat(createdProj, containsString(data.main), 'project contains main info');
    }

}