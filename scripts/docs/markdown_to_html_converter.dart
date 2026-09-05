import "dart:io";

import "package:markdown/markdown.dart";
import "package:path/path.dart";

const _mdExt = ".md";

final class MarkdownToHtmlConverter {
  const new({required this.directory});

  final Directory directory;

  Stream<(File, String)> convert({bool recursive = false}) async* {
    final entities = await directory
        .list(recursive: recursive, followLinks: false)
        .where((e) => e is File && extension(e.path) == _mdExt)
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
          _LocalLinkMdSyntax(directory: directory, localFiles: entitiesPaths),
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

      yield (htmlFile, htmlContent);
    }
  }
}

class _LocalLinkMdSyntax extends InlineSyntax {
  static const _pattern = r"\[([^\]]+)\]\(([^)]+\.md)\)";

  new({required this.directory, required this.localFiles}) : super(_pattern);

  final Directory directory;
  final Set<String> localFiles;

  @override
  bool onMatch(InlineParser parser, Match match) {
    final title = match.group(1)!;
    final Element element = .text("a", title);
    parser.addNode(element);

    final mdFilePath = match.group(2)!;
    final path = joinAll([directory.path, mdFilePath]);

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
