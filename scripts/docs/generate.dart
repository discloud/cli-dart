import "dart:io";

import "package:discloud/cli/runner.dart";
import "package:markdown/markdown.dart";
import "package:path/path.dart";

import "generate/commands.dart";
import "generate/index.dart";

void main() async {
  const docRootPath = "docs";
  const docsExt = ".md";

  final docRootDir = Directory(docRootPath);

  final runner = CliCommandRunner();

  await Future.wait([home(), commands(runner: runner)]);

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

    final htmlFile = File(joinAll([dirname(mdFile.path), htmlFilename]));

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
    final element = Element.text("a", title);
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
