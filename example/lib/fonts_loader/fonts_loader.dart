// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';

//create just an instance and void duplicate instance
final FontsLoader _instance = FontsLoader._();

///A simple class that charge all fonts available in this example
class FontsLoader {
  late final List<pw.Font> _pdffonts; // save valid pdf type fonts
  late final EmojisFonts emojiFont;
  late final SpecialUnicodeFonts unicodeFont;

  bool _configured = false;

  FontsLoader._() {
    unicodeFont = SpecialUnicodeFonts();
    emojiFont = EmojisFonts();
    _pdffonts = <pw.Font>[];
  }

  factory FontsLoader() {
    return _instance;
  }

  List<pw.Font> allFonts() {
    if (_configured) {
      return _pdffonts;
    }
    throw notConfiguredFonts();
  }

  pw.Font loraFont() {
    if (_configured) {
      return _pdffonts[0];
    }
    throw notConfiguredFonts();
  }

  pw.Font loraBoldFont() {
    if (_configured) return _pdffonts[1];
    throw notConfiguredFonts();
  }

  pw.Font loraItalicFont() {
    if (_configured) {
      return _pdffonts[2];
    }
    throw notConfiguredFonts();
  }

  pw.Font loraBoldItalicFont() {
    if (_configured) {
      return _pdffonts[3];
    }
    throw notConfiguredFonts();
  }

  pw.Font courierFont() {
    if (_configured) {
      return _pdffonts[4];
    }
    throw notConfiguredFonts();
  }

  pw.Font courierBoldFont() {
    if (_configured) {
      return _pdffonts[5];
    }
    throw notConfiguredFonts();
  }

  pw.Font courierItalicFont() {
    if (_configured) {
      return _pdffonts[6];
    }
    throw notConfiguredFonts();
  }

  pw.Font courierBoldItalicFont() {
    if (_configured) {
      return _pdffonts[7];
    }
    throw notConfiguredFonts();
  }

  pw.Font crimsonFont() {
    if (_configured) {
      return _pdffonts[8];
    }
    throw notConfiguredFonts();
  }

  pw.Font crimsonBoldFonts() {
    if (_configured) {
      return _pdffonts[9];
    }
    throw notConfiguredFonts();
  }

  pw.Font crimsonItalicFonts() {
    if (_configured) {
      return _pdffonts[10];
    }
    throw notConfiguredFonts();
  }

  pw.Font crimsonBoldItalicFonts() {
    if (_configured) {
      return _pdffonts[11];
    }
    throw notConfiguredFonts();
  }

  pw.Font philosopherFont() {
    if (_configured) {
      return _pdffonts[12];
    }
    throw notConfiguredFonts();
  }

  pw.Font philosopherBoldFont() {
    if (_configured) {
      return _pdffonts[13];
    }
    throw notConfiguredFonts();
  }

  pw.Font philosopherItalicFont() {
    if (_configured) {
      return _pdffonts[14];
    }
    throw notConfiguredFonts();
  }

  pw.Font philosopherBoldItalicFont() {
    if (_configured) {
      return _pdffonts[15];
    }
    throw notConfiguredFonts();
  }

  pw.Font tinosFont() {
    if (_configured) {
      return _pdffonts[20];
    }
    throw notConfiguredFonts();
  }

  pw.Font tinosBoldFont() {
    if (_configured) {
      return _pdffonts[21];
    }
    throw notConfiguredFonts();
  }

  pw.Font tinosItalicFont() {
    if (_configured) {
      return _pdffonts[22];
    }
    throw notConfiguredFonts();
  }

  pw.Font tinosBoldItalicFont() {
    if (_configured) {
      return _pdffonts[23];
    }
    throw notConfiguredFonts();
  }

  pw.Font notoFont() {
    if (_configured) {
      return _pdffonts[24];
    }
    throw notConfiguredFonts();
  }

  pw.Font notoBoldFont() {
    if (_configured) {
      return _pdffonts[25];
    }
    throw notConfiguredFonts();
  }

  pw.Font notoItalicFont() {
    if (_configured) {
      return _pdffonts[26];
    }
    throw notConfiguredFonts();
  }

  pw.Font notoBoldItalicFont() {
    if (_configured) {
      return _pdffonts[27];
    }
    throw notConfiguredFonts();
  }

  pw.Font openSansFont() {
    if (_configured) {
      return _pdffonts[28];
    }
    throw notConfiguredFonts();
  }

  pw.Font openSansBoldFont() {
    if (_configured) {
      return _pdffonts[29];
    }
    throw notConfiguredFonts();
  }

  pw.Font openSansItalicFont() {
    if (_configured) {
      return _pdffonts[30];
    }
    throw notConfiguredFonts();
  }

  pw.Font openSansBoldItalicFont() {
    if (_configured) {
      return _pdffonts[31];
    }
    throw notConfiguredFonts();
  }

  pw.Font inriaSerifFonts() {
    if (_configured) {
      return _pdffonts[32];
    }
    throw notConfiguredFonts();
  }

  pw.Font inriaSerifBoldFont() {
    if (_configured) {
      return _pdffonts[33];
    }
    throw notConfiguredFonts();
  }

  pw.Font inriaSerifItalicFont() {
    if (_configured) {
      return _pdffonts[34];
    }
    throw notConfiguredFonts();
  }

  pw.Font inriaSerifBoldItalicFont() {
    if (_configured) {
      return _pdffonts[35];
    }
    throw notConfiguredFonts();
  }

  pw.Font ubuntuMonoFont() {
    if (_configured) {
      return _pdffonts[41];
    }
    throw notConfiguredFonts();
  }

  pw.Font ubuntuMonoBoldFont() {
    if (_configured) {
      return _pdffonts[42];
    }
    throw notConfiguredFonts();
  }

  pw.Font ubuntuMonoItalicFont() {
    if (_configured) {
      return _pdffonts[43];
    }
    throw notConfiguredFonts();
  }

  pw.Font ubuntuMonoBoldItalicFont() {
    if (_configured) {
      return _pdffonts[44];
    }
    throw notConfiguredFonts();
  }

  pw.Font arialFont() {
    if (_configured) {
      return _pdffonts[36];
    }
    throw notConfiguredFonts();
  }

  pw.Font arialBoldFont() {
    if (_configured) {
      return _pdffonts[37];
    }
    throw notConfiguredFonts();
  }

  pw.Font arialItalicFont() {
    if (_configured) {
      return _pdffonts[38];
    }
    throw notConfiguredFonts();
  }

  pw.Font arialBoldItalicFont() {
    if (_configured) {
      return _pdffonts[39];
    }
    throw notConfiguredFonts();
  }

  Exception notConfiguredFonts() {
    return Exception('The fonts must be initalized before of take it');
  }

  pw.Font getFontByName(
      {String? fontFamily, bool bold = false, bool italic = false}) {
    assert(_configured);
    if (fontFamily == null) {
      if (bold && italic) {
        return pw.Font.helveticaBoldOblique();
      }
      if (bold) {
        return pw.Font.helveticaBold();
      }
      if (italic) {
        return pw.Font.helveticaOblique();
      }
      return pw.Font.helvetica();
    }
    if (fontFamily.equals('Tinos')) {
      if (bold && italic) {
        return tinosBoldItalicFont();
      }
      if (bold) {
        return tinosBoldFont();
      }
      if (italic) {
        return tinosItalicFont();
      }
      return tinosFont();
    }
    if (fontFamily.equals('Lora')) {
      if (bold && italic) {
        return loraBoldItalicFont();
      }
      if (bold) {
        return loraBoldFont();
      }
      if (italic) {
        return loraItalicFont();
      }
      return loraFont();
    }
    if (fontFamily.equals('arial') || fontFamily.equals('Arial')) {
      if (bold && italic) {
        return arialBoldItalicFont();
      }
      if (bold) {
        return arialBoldFont();
      }
      if (italic) {
        return arialItalicFont();
      }
      return arialFont();
    }
    if (fontFamily.equals('monospace')) {
      return pw.Font.courier();
    }
    if (fontFamily.equals('Noto Sans')) {
      if (bold && italic) {
        return notoBoldItalicFont();
      }
      if (bold) {
        return notoBoldFont();
      }
      if (italic) {
        return notoItalicFont();
      }
      return notoFont();
    }
    if (fontFamily.equals('Open Sans')) {
      if (bold && italic) {
        return openSansBoldItalicFont();
      }
      if (bold) {
        return openSansBoldFont();
      }
      if (italic) {
        return openSansItalicFont();
      }
      return openSansFont();
    }
    if (fontFamily.equals('Courier')) {
      if (bold && italic) {
        return courierBoldItalicFont();
      }
      if (bold) {
        return courierBoldFont();
      }
      if (italic) {
        return courierItalicFont();
      }
      return courierFont();
    }
    if (fontFamily.equals('Inria Serif')) {
      if (bold && italic) {
        return inriaSerifBoldItalicFont();
      }
      if (bold) {
        return inriaSerifBoldFont();
      }
      if (italic) {
        return inriaSerifItalicFont();
      }
      return inriaSerifFonts();
    }
    if (fontFamily.equals('Ubuntu Mono')) {
      if (bold && italic) {
        return ubuntuMonoBoldItalicFont();
      }
      if (bold) {
        return ubuntuMonoBoldFont();
      }
      if (italic) {
        return ubuntuMonoItalicFont();
      }
      return ubuntuMonoFont();
    }
    return _pdffonts[0];
  }

  Future<void> loadFonts() async {
    //LORA
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/lora/Lora-Regular.ttf")));
    _pdffonts.add(
        pw.Font.ttf(await rootBundle.load("assets/fonts/lora/Lora-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/lora/Lora-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/lora/Lora-BoldItalic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Courier/CourierPrime-Regular.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Courier/CourierPrime-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Courier/CourierPrime-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Courier/CourierPrime-BoldItalic.ttf")));
    _pdffonts.add(
        pw.Font.ttf(await rootBundle.load("assets/fonts/crimson/crimson.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/crimson/crimson-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/crimson/crimson-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/crimson/crimson-BoldItalic.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/philosopher/philosopher.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/philosopher/philosopher-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/philosopher/philosopher-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/philosopher/philosopher-BoldItalic.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/lobster/lobsterTwo.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/lobster/lobsterTwo-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/lobster/lobsterTwo-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/lobster/lobsterTwo-BoldItalic.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Tinos/Tinos-Regular.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Tinos/Tinos-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Tinos/Tinos-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Tinos/Tinos-BoldItalic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Noto_Sans/static/NotoSans-Regular.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Noto_Sans/static/NotoSans-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Noto_Sans/static/NotoSans-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Noto_Sans/static/NotoSans-BoldItalic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Open_Sans/static/OpenSans-Regular.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Open_Sans/static/OpenSans-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Open_Sans/static/OpenSans-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Open_Sans/static/OpenSans-BoldItalic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Inria_Serif/InriaSerif-Regular.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Inria_Serif/InriaSerif-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Inria_Serif/InriaSerif-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Inria_Serif/InriaSerif-BoldItalic.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Lato/Lato-Regular.ttf")));
    _pdffonts.add(
        pw.Font.ttf(await rootBundle.load("assets/fonts/Lato/Lato-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Lato/Lato-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Lato/Lato-BoldItalic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Raleway/Raleway-VariableFont_wght.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Ubuntu_Mono/UbuntuMono-Regular.ttf")));
    _pdffonts.add(pw.Font.ttf(
        await rootBundle.load("assets/fonts/Ubuntu_Mono/UbuntuMono-Bold.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Ubuntu_Mono/UbuntuMono-Italic.ttf")));
    _pdffonts.add(pw.Font.ttf(await rootBundle
        .load("assets/fonts/Ubuntu_Mono/UbuntuMono-BoldItalic.ttf")));
    _configured = true;
  }
}

class EmojisFonts {
  late final pw.Font emojisFonts;
  late final String keyFont;
  EmojisFonts() {
    init();
  }
  void init() async {
    keyFont = "NotoEmojis";
    emojisFonts = pw.Font.ttf(await rootBundle.load(
        "assets/fonts/unicodes/Noto_Emoji/NotoEmoji-VariableFont_wght.ttf"));
  }
}

class SpecialUnicodeFonts {
  late final pw.Font unicode;
  SpecialUnicodeFonts() {
    init();
  }
  void init() async {
    unicode = pw.Font.symbol();
  }
}
