package hxcs.tests.system;

import haxe.io.Bytes;
import haxe.io.Path;
import hxcs.fakes.SystemFake;

import org.hamcrest.Matchers.*;

using compiler.cs.system.SystemTools;
using DateTools;


class SystemToolsTest {
    var system:SystemFake;
    var fileCounter:Int=0;

    public function new() {
    }

    @Before
    public function setup() {
        system = new SystemFake();
        fileCounter = 0;
    }

    @Test
    public function add_base_path() {
        final absolute = "/absolute/path";
        final relative = "relative/path";
        final relative2 = "relative2";
        final ignore_absolute = "/ignore";
        final ignore_relative = "ignore/path";
        final win_net_abs = "\\network\\path";
        final win_absolute = "C:\\win\\absolute\\path";

        test_add_base_path(
            "Add relatives", relative, relative2, Path.join([relative, relative2]));
        test_add_base_path(
            "Absolute + relative", absolute, relative, Path.join([absolute, relative]));

        test_add_base_path("No path", relative, "", relative);
        test_add_base_path("No base", "", relative, Path.join(['.', relative]));

        for (ignore_path in [ignore_absolute, ignore_relative]){
            test_add_base_path("Absolute unix path"   , ignore_path, absolute, absolute);
            test_add_base_path("Absolute win network" , ignore_path, win_net_abs, win_net_abs);
            test_add_base_path("Absolute windown path", ignore_path, win_absolute, win_absolute);
        }
    }

    function test_add_base_path(caseName:String, basePath:String, path:String, expected:String) {
        assertThat(path.addBasePath(basePath), equalTo(expected),
            'test_add_base_path[$caseName]: addPath("$basePath", "$path") should be "$expected"'
        );
    }

    @Test
    public function copy_file() {
        var content = 'Lorem ipsum dolor sit amet';

        var from = givenFileWithContent(content);
        var dst = from + ".copy";

        system.copy(from, dst);

        assertCopied(from, dst, content);
    }

    @Test
    public function copy_if_is_newer() {
        test_copy_if_newer(Date.now(), null);
        test_copy_if_newer(Date.now(), Date.now().delta(1000), false);
        test_copy_if_newer(Date.now(), Date.now().delta(-1000), true);
    }

    function test_copy_if_newer(
        srcModified:Date, dstModified:Date, shouldCopy:Bool=true)
    {
        var content = 'example';
        var file = givenFileWithContent(content, srcModified);

        var previousContent = null;
        var fileDst = file + ".copy";

        if(dstModified != null){
            var dstContent = 'other example';
            fileDst = givenFileWithContent(dstContent, dstModified);
            previousContent = Bytes.ofString(dstContent);
        }

        system.copyIfNewer(file, fileDst);

        if(shouldCopy){
            assertCopied(file, fileDst, content);
        }
        else {
            assertFileContentIs(fileDst, previousContent);
        }
    }

    @Test
    public function test_copy_tree() {
        var srcRoot = '/src';
        var dstRoot = '/dst';
        var filenames = ['a', 'd1/b', 'd2/c', 'd3/d4/d'];
        var files = [for(f in filenames) Path.join([srcRoot, f])];
        var contents = [ for(f in files) f => givenFile(f, Bytes.ofString(f))];

        system.copyTreeNewer(srcRoot, dstRoot);

        for(f in filenames){
            var srcFile = Path.join([srcRoot, f]);
            var dstFile = Path.join([dstRoot, f]);

            assertCopied(srcFile, dstFile, contents[srcFile].toString());
        }
    }

    // helper ---------------------------------------------

    function givenFileWithContent(content:String, ?modifiedDate:Date) {
        var path = 'file${++fileCounter}';
        givenFile(path, Bytes.ofString(content));

        if(modifiedDate != null){
            setModifiedDate(path, modifiedDate);
        }

        return path;
    }

    function setModifiedDate(filePath:String, modifiedDate:Date) {
        var stat = system.files.stat(filePath);
        stat.mtime = modifiedDate;

        system.files.setStat(filePath, stat);
    }

    function givenFile(path:String, content:Bytes) {
        system.saveBytes(path, content);

        return content;
    }

    function assertCopied(from:String, dst:String, content:String) {
        var copiedBytes = system.getBytes(dst);

        assertThat(copiedBytes, is(notNullValue()),
            'Should have copied bytes from "$from" to "$dst"');
        assertFileContentIs(dst, copiedBytes);
    }
    function assertFileContentIs(path:String, expectedContent:Null<Bytes>) {
        var actualContent = system.getBytes(path);

        if(expectedContent == null){
            assertThat(actualContent, is(nullValue()),
                'Path $path should have no content');
        }
        else {
            assertThat(actualContent, is(notNullValue()),
                'Path $path should not be null');

            assertThat(actualContent.toString(), equalTo(expectedContent.toString()),
                'File "$path" content does not match the expectation'
            );
        }

    }
}