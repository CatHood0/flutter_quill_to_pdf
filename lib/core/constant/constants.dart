class Constant {
  const Constant._();
  static const String WHITESPACE = ' ';
  static const String DEFAULT_OBJECT_FIT = 'contain';
  static const double DEFAULT_LINE_HEIGHT = 1.0;
  static const int DEFAULT_FONT_SIZE = 12;
  static const String DEFAULT_FONT_FAMILY = 'Arial';
  //to encode markdown characters to avoid detection
  //[ | ]
  static const String ENCODED_BRACKETS_SYMBOL_LEFT = 'þ@hcpsl';
  static const String ENCODED_BRACKETS_SYMBOL_RIGHT = 'þ@hcpsr';
  //{ | }
  static const String ENCODED_KEY_SYMBOL_LEFT = 'þ@kcpsl';
  static const String ENCODED_KEY_SYMBOL_RIGHT = 'þ@kcpsr';
  // * | *** | **_ | _** | *__* | _w_ | ***_ | _*** | # header
  static const String ENCODED_MD_HEADER_SYMBOL = 'þ@hbp';
  static const String ENCODED_MD_BOLD_SYMBOL = 'þ@bs';
  static const String ENCODED_MD_ITALIC_SYMBOL = 'þ@emp';
  static const String ENCODED_MD_UNDERLINE_SYMBOL = 'þ@us';
  static const String ENCODED_MD_BOLDITALIC_SYMBOL = 'þ@bemsp';
  static const String ENCODED_MD_UNDERLINE_ITALIC_LEFT = 'þ@uemspl';
  static const String ENCODED_MD_UNDERLINE_ITALIC_RIGHT = 'þ@uemspr';
  static const String ENCODED_MD_UNDERLINE_BOLD_SYMBOL_LEFT = 'þ@ubspl';
  static const String ENCODED_MD_UNDERLINE_BOLD_SYMBOL_RIGHT = 'þ@ubspl';
  static const String ENCODED_MD_ALL_SYMBOL_LEFT = 'þ@ubemspl';
  static const String ENCODED_MD_ALL_SYMBOL_RIGHT = 'þ@ubemspr';
  static const String EMPTY_DELTA_ATTRIBUTES = r'"attributes":{}';
  static const String ENCODED_QUOTE_SYMBOL = 'þ@quwmbp';

  static const List<double> default_heading_size = <double>[37, 30, 24, 18, 12];
  static const List<String> default_editor_spacing = <String>[
    '1.0',
    '1.15',
    '1.5',
    '2.0'
  ];
  static const Map<String, String> fontSizes = <String, String>{
    "Tiny": "small",
    "Normal": "16", //clear to make the transform assign DEFAULT_FONT_SIZE -> 12
    "Large": "large",
    "Huge": "huge",
    "Subtitle": "23",
    "Title": "28",
  };

  static const Map<String, String> fontFamilies = <String, String>{
    "Monospace": "monospace",
    "Arial": "arial",
    "Courier": "Courier",
    "Inria Serif": "Inria Serif",
    "Noto Sans": "Noto Sans",
    "Open Sans": "Open Sans",
    "Ubuntu Mono": "Ubuntu Mono",
    "Tinos": "Tinos",
  };

  static final RegExp newLinesInsertions = RegExp(r'^¶+');

  static final RegExp rawDeltaNewLines = RegExp(r'^\\n{1,}(?!(.+?))');
  //TODO: implement this images regex to improve support of network and local images (and base64)
  static final RegExp IMAGE_LOCAL_STORAGE_PATH_PATTERN =
      RegExp(r'^((\/[a-zA-Z0-9-_]+)+|\/)$');
  static final RegExp IMAGE_FROM_NETWORK_URL = RegExp(
      r'^(?:(?<scheme>[^:\/?#]+):)?(?:\/\/(?<authority>[^\/?#]*))?(?<path>[^?#]*\/)?(?<file>[^?#]*\.(?<extension>[Jj][Pp][Ee]?[Gg]|[Pp][Nn][Gg]|[Gg][Ii][Ff]))(?:\?(?<query>[^#]*))?(?:#(?<fragment>.*))?$');
  //HTML PATTERNS
  static final RegExp NEWLINE_WITH_SPACING_PATTERN =
      RegExp(r'^(<span\s*style="line-height:\s*(\d+.\d+|\d+)">(\n)+<\/span>)$');
  static final RegExp STARTS_WITH_RICH_TEXT_INLINE_STYLES_PATTERN = RegExp(
      r'^(<span\s*style="((color:(#.+?|(rgb\((\d+),\s*(\d+),\s*(\d+)\)));?)?)((background-color:(#.+?|(rgb\((\d+),\s*(\d+),\s*(\d+)\)));?)?)((wiki-doc:\s*(.+?);?)?)((line-height:\s*(.+?);?)?)(font-family:\s*(.+?);?)?((font-size:\s*(\d+.\d+|\d+)(px|em|rem))?)">(.*?)<\/span>)');
  /*
    TEXT COLOR
      4 hex color
      5 rgb (full string) -> 6 (red) | 7 (green) | 8 (blue)
    BACKGROUND COLOR
      11 hex color
      12 rgb (full string) -> 13 (red) | 14 (green) | 15 (blue)
    WIKI
      18 link to document
    ATTRIBUTES
      21 Line-height
      23 Font family
      26 text size
    CONTENT
      28 content span
  */
  static final RegExp RICH_TEXT_INLINE_STYLES_PATTERN = RegExp(
      r'(<span\s*style="((color:(#.+?|(rgb\((\d+),\s*(\d+),\s*(\d+)\)));?)?)((background-color:(#.+?|(rgb\((\d+),\s*(\d+),\s*(\d+)\)));?)?)((wiki-doc:\s*(.+?);?)?)((line-height:\s*(.+?);?)?)(font-family:\s*(.+?);?)?((font-size:\s*(\d+.\d+|\d+)(px|em|rem))?)">(.*?)<\/span>)');
  static final RegExp EMPTY_ALIGNED_H = RegExp(
      r'^<h([1-6])\s+style="text-align:(center|right|left|justify)">(([<br>]+)|(<span.*?>[<br>]+<\/span>))+<\/h\1>$');
  static final RegExp EMPTY_ALIGNED_P = RegExp(
      r'^<p\s+style="text-align:(center|right|left|justify)">(([<br>]+)|(<span.*?>[<br>]+<\/span>))<\/p>$');
  static final RegExp ALIGNED_P_PATTERN =
      RegExp(r'<p\s?style="text-align:(center|right|justify|left)">(.+?)<\/p>');
  static final RegExp ALIGNED_P_INDENTED_PATTERN = RegExp(
      r'<p\s?style="padding-left:(\d+)em;text-align:(center|right|left|justify)">(.*)<\/p>');
  static final RegExp ALIGNED_P_IMAGE_PATTERN = RegExp(
      r'<img\s*style="max-width:\s*(.*?)%;object-fit:\s*(contain|cover|none|fill)"\s*src="(.+)">');
  static final RegExp ALIGNED_HEADER_PATTERN = RegExp(
      r'<h([1-6]) style="text-align:(center|right|left|justify)">(.+)<\/h\1>');
  static final RegExp LIST_CHECK_PATTERN = RegExp(
      r'<li\s?(style="((text-align:(center|right|left|justify));)?(list-style-type:(.+?);(padding-left:(.*?)em));"\s?(data-checked="(false|true)"))>(.+?)<\/li>');
  static final RegExp LINK_ALIGNED_PATTERN = RegExp(
      r'(.*?)(<a\s+href="(.+?)"\s+target="(.+?)">(.*?)<\/a>)|((.*?)<\/p>)');
  //HTML_LINK_TAGS_PATTERN
  //group 5 takes the line height,
  //group 9 takes the font family,
  //group 10 takes the font size,
  //group 11 takes the href
  //group 12 takes the target
  // group 13 takes the content
  static final RegExp HTML_LINK_TAGS_PATTERN = RegExp(
      r'(<a(\s*style="((line-height:\s*(.*?);?)?)((font-family:\s*(.*?);?)?)(font-size:\s*(\d+.\d+|\d+)px)?")?\s*href="(.+?)"\s*?target="(.+?)">(.+?)<\/a>)');
  //Matches with <p style="text-align:center"><img style="max-width: 100%;object-fit: contain;;" src="/data/user/0/com.example.x/cache/93c1785c-c0d5-4416-b622-94f8163c8fce/1000172526.jpg"></p>
  static final RegExp HTML_IMAGE_PATTERN = RegExp(
      r'<p\s+style="text-align:(center|right|left|justify)">(<img .*?>)<\/p>$');
  static final RegExp BLOCKQUOTE_PATTERN =
      RegExp(r"<blockquote>(.+?)<\/blockquote>", multiLine: true);
  static final RegExp CODE_PATTERN =
      RegExp(r"<pre>(.*?)<\/pre>|<code>(.*?)<\/code>", multiLine: true);

  //MARKDOWN PATTERNS
  static final RegExp LIST_CHECK_MD_PATTERN =
      RegExp(r'^(-\s?\[(x|\s{1})\](\[(center|right|left|justify)\])?\s)(.+)$');
  // groups: 1 -> max-width, 2 -> object-fit, 3 -> margin (could be null), 4 -> top|bottom mar, 5 -> type center (auto), 6 -> width (could be null), 7 -> width size, 8 -> height (could be null), 9 -> height size, 10 -> source
  static final RegExp IMAGE_PATTERN = RegExp(
      r'!\[max-width:\s?(\d+%);object-fit:\s?(cover|fill|contain|fitWidth|fitHeight|none|scale-down|fill-all);?(margin:\s?(\d+px) (auto))?;?(width: (\d+.\d+|\d+))?;?(\s?height:\s?(\d+.\d+|\d+))?;?\s{0,3}\]\s?\((.*?)\)$');
  static final RegExp IMAGE_PATTERN_IN_SPAN = RegExp(
      r'<span style=".+?">(!\[max-width:\s?(\d+%);object-fit:\s?(cover|fill|contain|fitWidth|fitHeight|none|scale-down|fill-all);?(margin:\s?(\d+px) (auto))?;?(width: (\d+.\d+|\d+))?;?(\s?height:\s?(\d+.\d+|\d+))?;?\s{0,3}\]\s?\((.*?)\))<\/span>');

  static final RegExp HEADER_PATTERN = RegExp(r'(^#{1,6})\s{1}(.*)');
  static final RegExp LINK_PATTERN = RegExp(
      r'\[(.+?)\]\s?\(([(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*))\)');
  static final RegExp LIST_PATTERN =
      RegExp(r'^(\d+|\w+\.|[*+-](?![*]))\s{1,1}(.+)');
  static final RegExp INLINE_STYLES_PATTERN =
      RegExp(r'(\*\*\*|\*\*|\*|_|~~)(.+?)(\1)');
  static final RegExp INLINE_MATCHER = RegExp(
      r'((\*\*\*(?<boldItalic>(?:(?!\*\*\*).)+)\*\*\*)|(\*\*(?<bold>(?:(?!\*\*).)+)\*\*)|(\*(?<italic>[^*]+)\*)|(\_(?<underline>[^_]+)\_)|(\*\*\*\_(?<boldItalicUnderline>(?:(?!\_\*\*\*).)+)\_\*\*\*)|(~~(?<strike>(?:(?!~~).)+)~~))|(\[(?<linkTitle>[^]]+)]\((?<linkHref>.*)\)|(<a\sstyle="((wiki-doc:\s*(.*?);)?)((line-height:\s*(.*?);?)?)((font-family:\s*(.*?);?)?)(font-size:\s*(\d+.\d+|\d+))?"\shref="(.+?)"\s?target="(.+?)">(.+?)<\/a>))');

  //Wrong and invalids patterns
  static final RegExp INVALID_HEADER_PATTERN = RegExp(
      r'^\s{0,}(#){1,}((?!\w|\d+)\s{0,}?(#)+)+$'); // detect some strnigs like: # # # # #
  static final RegExp INVALID_TOGGLEABLE_STYLES_PATTERN = RegExp(
      r'^\s{0,}(\*)+((?!\w|\d+)\s{0,}?(\*)+)+$'); // detect some strnigs like: * * * * *
  //Avoid errors by font size style in image (TODO: fix it)
  static final RegExp WRONG_IMAGE_MATCHING = RegExp(
      r'!\[(max-width:\s?(\d+%);object-fit:\s?(cover|fill|contain|fitWidth|fitHeight|none|scale-down|fill-all);?(margin:\s?(\d+px) (auto))?;?(width: (\d+.\d+|\d+))?;?(\s?height:\s?(\d+.\d+|\d+))?;?\s{0,3});font-size:\s*(\d+.\d+|\d+)px?\]\s?\((.*?)\)$');
  //WRONG PASTING STYLES (comes from html converter that takes and put styles into tags incorrectly)
  //convert: -> <strong style="line-height: x;font-size: x">Words</strong>
  //to: <span style="line-height: x;font-size: x><strong>Words</strong></span>
  //group 1: append tags, group 3: styles (all), group 4: content, group 5: close tag (-> break at this point)
  static final RegExp STRONG_WITH_WRONG_STYLES_PATTER =
      RegExp(r'(.*?)(<strong\s*(style=".*?")>(.+?)<\/strong>)|(.*)');
  static final RegExp EMPHASIS_WITH_WRONG_STYLES_PATTER =
      RegExp(r'(.*?)(<em\s*(style=".*?")>(.+?)<\/em>)|(.*)');
  static final RegExp UNDERLINE_WITH_WRONG_STYLES_PATTER =
      RegExp(r'(.*?)(<u\s*(style=".*?")>(.+?)<\/u>)|(.*)');
}
