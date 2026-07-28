import "dart:io";
import "dart:typed_data";

import "package:args/command_runner.dart";
import "package:discloud/cli/runner.dart";
import "package:discloud/version.dart";
import "package:markdown/markdown.dart";
import "package:path/path.dart";

import "generate/commands.dart";
import "generate/index.dart";

const _filesToPreserve = {"_config.yml"};

void main() async {
  const docRootPath = "docs";
  const docsExt = ".md";

  final Directory docRootDir = .new(docRootPath);

  final filesToPreserveContents = <String, Uint8List>{};

  for (final filename in _filesToPreserve) {
    final File file = .new(joinAll([docRootDir.path, filename]));
    if (!await file.exists()) continue;

    filesToPreserveContents[file.path] = await file.readAsBytes();
  }

  await docRootDir.delete(recursive: true);
  await docRootDir.create(recursive: true);

  for (final entry in filesToPreserveContents.entries) {
    final File file = .new(entry.key);
    await file.writeAsBytes(entry.value, flush: true);
  }

  const version = packageVersion == "0.0.0" ? "" : " v$packageVersion";

  const header = "# [CLI Documentation$version](index.md)\n";

  final CommandRunner<void> runner = CliCommandRunner();

  await Future.wait([
    home(header: header),
    commands(header: header, runner: runner),
  ]);

  final entities = await docRootDir
      .list(recursive: true)
      .where((e) => e is File && extension(e.path) == docsExt)
      .toList();

  final entitiesPaths = entities.map((e) => e.path).toSet();

  for (final mdFile in entities.whereType<File>()) {
    final mdContent = await mdFile.readAsString();

    final htmlContent = markdownToHtml(
      mdContent,
      blockSyntaxes: const [
        AlertBlockSyntax(),
        BlockquoteSyntax(),
        CodeBlockSyntax(),
        DummyBlockSyntax(),
        EmptyBlockSyntax(),
        FencedBlockquoteSyntax(),
        FencedCodeBlockSyntax(),
        FootnoteDefSyntax(),
        HeaderSyntax(),
        HeaderWithIdSyntax(),
        HorizontalRuleSyntax(),
        HtmlBlockSyntax(),
        LinkReferenceDefinitionSyntax(),
        OrderedListSyntax(),
        OrderedListWithCheckboxSyntax(),
        ParagraphSyntax(),
        SetextHeaderSyntax(),
        SetextHeaderWithIdSyntax(),
        TableSyntax(),
        UnorderedListSyntax(),
        UnorderedListWithCheckboxSyntax(),
      ],
      inlineSyntaxes: [
        _LocalLinkMdSyntax(
          localFileList: entitiesPaths,
          relativeRootPath: docRootPath,
        ),
        AutolinkSyntax(),
        AutolinkExtensionSyntax(),
        CodeSyntax(),
        ColorSwatchSyntax(),
        DecodeHtmlSyntax(),
        EmailAutolinkSyntax(),
        EmojiSyntax(),
        EmphasisSyntax.asterisk(),
        EmphasisSyntax.underscore(),
        EscapeHtmlSyntax(),
        EscapeSyntax(),
        ImageSyntax(),
        InlineHtmlSyntax(),
        LineBreakSyntax(),
        LinkSyntax(),
        SoftLineBreakSyntax(),
        StrikethroughSyntax(),
      ],
    );

    final htmlFilename = "${basenameWithoutExtension(mdFile.path)}.html";

    final File htmlFile = .new(joinAll([dirname(mdFile.path), htmlFilename]));

    await htmlFile.writeAsString(htmlContent);
  }
}

class _LocalLinkMdSyntax extends InlineSyntax {
  _LocalLinkMdSyntax({
    required this.relativeRootPath,
    required this.localFileList,
  }) : super(r"\[([^\]]+)\]\((.+.md)\)");

  final String relativeRootPath;
  final Set<String> localFileList;

  @override
  bool onMatch(InlineParser parser, Match match) {
    final title = match.group(1)!;
    final Element element = .text("a", title);
    parser.addNode(element);

    final mdFilePath = match.group(2)!;
    final path = joinAll([relativeRootPath, mdFilePath]);
    if (localFileList.contains(path)) {
      final htmlFilename = "${basenameWithoutExtension(mdFilePath)}.html";
      final htmlFilepath = joinAll([dirname(mdFilePath), htmlFilename]);
      element.attributes["href"] = htmlFilepath;
      return true;
    }
    element.attributes["href"] = mdFilePath;
    return true;
  }
}
