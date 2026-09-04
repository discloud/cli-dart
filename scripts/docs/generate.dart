// dart scripts/docs/generate.dart

import "dart:io";
import "dart:typed_data";

import "package:args/command_runner.dart";
import "package:discloud/cli/runner.dart";
import "package:discloud/version.dart";
import "package:markdown/markdown.dart";
import "package:path/path.dart";

import "generate/commands.dart";
import "generate/index.dart";

const _docsRootPath = "docs";
const _mdDocsExt = ".md";

void main() async {
  final docRootDir = Directory(_docsRootPath);

  const filesToPreserve = {"_config.yml"};
  final filesToPreserveContents = <File, Uint8List>{};

  for (final filename in filesToPreserve) {
    final File file = .new(joinAll([_docsRootPath, filename]));
    if (!await file.exists()) continue;

    filesToPreserveContents[file] = await file.readAsBytes();
  }

  await docRootDir.delete(recursive: true);
  await docRootDir.create(recursive: true);

  for (final entry in filesToPreserveContents.entries) {
    await entry.key.writeAsBytes(entry.value, flush: true);
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
      .where((e) => e is File && extension(e.path) == _mdDocsExt)
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
        _LocalLinkMdSyntax(localFiles: entitiesPaths),
        AutolinkExtensionSyntax(),
        AutolinkSyntax(),
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
  static const _pattern = r"\[([^\]]+)\]\(([^)]+\.md)\)";

  new({required this.localFiles}) : super(_pattern);

  final Set<String> localFiles;

  @override
  bool onMatch(InlineParser parser, Match match) {
    final title = match.group(1)!;
    final Element element = .text("a", title);
    parser.addNode(element);

    final mdFilePath = match.group(2)!;
    final path = joinAll([_docsRootPath, mdFilePath]);

    if (localFiles.contains(path)) {
      final htmlFilename = "${basenameWithoutExtension(mdFilePath)}.html";
      final htmlFilePath = joinAll([dirname(mdFilePath), htmlFilename]);
      element.attributes["href"] = htmlFilePath;
      return true;
    }

    element.attributes["href"] = mdFilePath;
    return true;
  }
}
