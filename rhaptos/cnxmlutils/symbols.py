"""
Copyright (C) 2013 Rice University

This software is subject to the provisions of the GNU AFFERO GENERAL PUBLIC LICENSE Version 3.0 (AGPL).  
See LICENSE.txt for details.
"""

""" Replace high unicode symbols found in some documents
    with characters with lower code points """

#
# Microsoft Symbol fonts - U+F020..U+F0FF (unicode private use area)
#
UNICODE_DICTIONARY = {
  # wierd MS symbol font back flips
    "&#xE09E;":"("            # (
  , "&#xE09F;":")"            # )

  # known MS private use area unicode UTF-8 characters
  , "&#xEF80A0;":"&#32;"    # U+0020 SPACE, UTF-8: 0x20
  , "&#xEF80A2;":"&#8704;"  # U+2200 FOR ALL, UTF-8: 0xE2 0x88 0x80
  , "&#xEF80A4;":"&#8707;"  # U+2203 THERE EXISTS, UTF-8: 0xE2 0x88 0x83
  , "&#xEF80A8;":"&#40;"    # U+0028 LEFT PARENTHESIS, UTF-8: 0x28
  , "&#xEF80A9;":"&#41;"    # U+0029 RIGHT PARENTHESIS, UTF-8: 0x29
  , "&#xEF80AC;":"&#65104;" # U+FE50 SMALL COMMA, UTF-8: 0xEF 0xB9 0x90
                              # or U+002C COMMA
  , "&#xEF80AD;":"&#65293;" # U+FF0D FULLWIDTH HYPHEN-MINUS, UTF-8: 0xEF 0xBC 0x8D
  , "&#xEF80AE;":"&#46;"    # U+002E FULL STOP, UTF-8: 0x2E
  , "&#xEF80B2;":"&#178;"   # U+00B2 SUPERSCRIPT TWO, UTF-8: 0xC2 0xB2
  , "&#xEF80BC;":"&#60;"    # U+003C LESS-THAN SIGN, UTF-8: 0x3C
  , "&#xEF80BD;":"&#61;"    # U+003D EQUALS SIGN, UTF-8: 0x3D
  , "&#xEF8180;":"&#8773;"  # U+2245 APPROXIMATELY EQUAL TO, UTF-8: 0xE2 0x89 0x85
  , "&#xEF8183;":"&#935;"   # U+03A7 GREEK CAPITAL LETTER CHI, UTF-8: 0xCE 0xA7
  , "&#xEF8184;":"&#916;"   # U+0394 GREEK CAPITAL LETTER DELTA, UTF-8: 0xCE 0x94
  , "&#xEF8187;":"&#915;"   # U+0393 GREEK CAPITAL LETTER GAMMA, UTF-8: 0xCE 0x93
  , "&#xEF818D;":"&#924;"   # U+039C GREEK CAPITAL LETTER MU, UTF-8: 0xCE 0x9C
  , "&#xEF8190;":"&#928;"   # U+03A0 GREEK CAPITAL LETTER PI, UTF-8: 0xCE 0xA0
  , "&#xEF8191;":"&#929;"   # U+03A1 GREEK CAPITAL LETTER RHO, UTF-8: 0xCE 0xA1
  , "&#xEF8193;":"&#931;"   # U+03A3 GREEK CAPITAL LETTER SIGMA, UTF-8: 0xCE 0xA3
  , "&#xEF8194;":"&#932;"   # U+03A4 GREEK CAPITAL LETTER TAU, UTF-8: 0xCE 0xA4
  , "&#xEF819E;":"&#8869;"  # U+22A5 UP TACK, UTF-8: 0xE2 0x8A 0xA5
  , "&#xEF81A1;":"&#945;"   # U+03B1 GREEK SMALL LETTER ALPHA, UTF-8: 0xCE 0xB1
  , "&#xEF81A2;":"&#946;"   # U+03B2 GREEK SMALL LETTER BETA, UTF-8: 0xCE 0xB2
  , "&#xEF81A3;":"&#947;"   # U+03B3 GREEK SMALL LETTER GAMMA, UTF-8: 0xCE 0xB3
  , "&#xEF81A4;":"&#948;"   # U+03B4 GREEK SMALL LETTER DELTA, UTF-8: 0xCE 0xB4
  , "&#xEF81A5;":"&#949;"   # U+03B5 GREEK SMALL LETTER EPSILON, UTF-8: 0xCE 0xB5
  , "&#xEF81A6;":"&#981;"   # U+03D5 GREEK PHI SYMBOL, UTF-8: 0xCF 0x95
                              # or  U+03C6 GREEK SMALL LETTER PHI
  , "&#xEF81AA;":"&#966;"   # U+03C6 GREEK SMALL LETTER PHI, UTF-8: 0xCF 0x86
  , "&#xEF81AB;":"&#954;"   # U+03BA GREEK SMALL LETTER KAPPA, UTF-8: 0xCE 0xBA
  , "&#xEF81AC;":"&#955;"   # U+03BB GREEK SMALL LETTER LAMDA, UTF-8: 0xCE 0xBB
  , "&#xEF81AD;":"&#956;"   # U+03BC GREEK SMALL LETTER MU, UTF-8: 0xCE 0xBC
                              # or U+00B5 MICRO SIGN
  , "&#xEF81AE;":"&#957;"   # U+03BD GREEK SMALL LETTER NU, UTF-8: 0xCE 0xBD
  , "&#xEF81AF;":"&#959;"   # U+03BF GREEK SMALL LETTER OMICRON, UTF-8: 0xCE 0xBF
  , "&#xEF81B0;":"&#960;"   # U+03C0 GREEK SMALL LETTER PI, UTF-8: 0xCF 0x80
                              # or U+03D6 GREEK PI SYMBOL
  , "&#xEF81B1;":"&#952;"   # U+03B8 GREEK SMALL LETTER THETA, UTF-8: 0xCE 0xB8
  , "&#xEF81B2;":"&#961;"   # U+03C1 GREEK SMALL LETTER RHO, UTF-8: 0xCF 0x81
  , "&#xEF81B3;":"&#963;"   # U+03C3 GREEK SMALL LETTER SIGMA, UTF-8: 0xCF 0x83
  , "&#xEF81B4;":"&#964;"   # U+03C4 GREEK SMALL LETTER TAU, UTF-8: 0xCF 0x84
  , "&#xEF81B5;":"&#965;"   # U+03C5 GREEK SMALL LETTER UPSILON, UTF-8: 0xCF 0x85
  , "&#xEF81B7;":"&#969;"   # U+03C9 GREEK SMALL LETTER OMEGA, UTF-8: 0xCF 0x89
  , "&#xEF81BA;":"&#950;"   # U+03B6 GREEK SMALL LETTER ZETA, UTF-8: 0xCE 0xB6
  , "&#xEF81BC;":"&#124;"   # U+007C VERTICAL LINE, UTF-8: 0x7C
  , "&#xEF81BE;":"&#8764;"  # U+223C TILDE OPERATOR, UTF-8: 0xE2 0x88 0xBC
  , "&#xEF82A3;":"&#8804;"  # U+2264 LESS-THAN OR EQUAL TO, UTF-8: 0xE2 0x89 0xA4
  , "&#xEF82A5;":"&#8734;"  # U+221E INFINITY, UTF-8: 0xE2 0x88 0x9E
  , "&#xEF82AE;":"&#8594;"  # U+2192 RIGHTWARDS ARROW, UTF-8: 0xE2 0x86 0x92
  , "&#xEF82B0;":"&#176;"   # U+00B0 DEGREE SIGN, UTF-8: 0xC2 0xB0
  , "&#xEF82B1;":"&#177;"   # U+00B1 PLUS-MINUS SIGN,  UTF-8: 0xC2 0xB1
  , "&#xEF82B3;":"&#8805;"  # U+2265 GREATER-THAN OR EQUAL TO, UTF-8: 0xE2 0x89 0xA5
  , "&#xEF82B4;":"&#215;"   # U+00D7 MULTIPLICATION SIGN, UTF-8: 0xC3 0x97
  , "&#xEF82B9;":"&#8800;"  # U+2260 NOT EQUAL TO, UTF-8: 0xE2 0x89 0xA0
  , "&#xEF82BB;":"&#8776;"  # U+2248 ALMOST EQUAL TO, UTF-8: 0xE2 0x89 0x88
  , "&#xEF82BC;":"&#8230;"  # U+2026 HORIZONTAL ELLIPSIS, UTF-8: 0xE2 0x80 0xA6
  , "&#xEF8386;":"&#8709;"  # U+2205 EMPTY SET, UTF-8: 0xE2 0x88 0x85
  , "&#xEF838A;":"&#8839;"  # U+2287 SUPERSET OF OR EQUAL TO, UTF-8: 0xE2 0x8A 0x87
  , "&#xEF838C;":"&#8834;"  # U+2282 SUBSET OF, UTF-8: 0xE2 0x8A 0x82
  , "&#xEF838D;":"&#8838;"  # U+2286 SUBSET OF OR EQUAL TO, UTF-8: 0xE2 0x8A 0x86
  , "&#xEF838E;":"&#8712;"  # U+2208 ELEMENT OF, UTF-8: 0xE2 0x88 0x88
  , "&#xEF838F;":"&#8713;"  # U+2209 NOT AN ELEMENT OF, UTF-8: 0xE2 0x88 0x89
  , "&#xEF8399;":"&#8743;"  # U+2227 LOGICAL AND, UTF-8: 0xE2 0x88 0xA7
  , "&#xEF839A;":"&#8744;"  # U+2228 LOGICAL OR, UTF-8: 0xE2 0x88 0xA8
  , "&#xEF839B;":"&#8660;"  # U+21D4 LEFT RIGHT DOUBLE ARROW, UTF-8: 0xE2 0x87 0x94
  , "&#xEF839C;":"&#8656;"  # U+21D0 LEFTWARDS DOUBLE ARROW, UTF-8: 0xE2 0x87 0x90
  , "&#xEF839E;":"&#8658;"  # U+21D2 RIGHTWARDS DOUBLE ARROW, UTF-8: 0xE2 0x87 0x92
  , "&#xEF83A0;":"&#8594;"  # U+2192 RIGHTWARDS ARROW, UTF-8: 0xE2 0x86 0x92


  # known MS private use area unicode entity references
  , "&#xF020;":"&#32;"
  , "&#xF041;":"&#33;"
  , "&#xF042;":"&#8704;"
  , "&#xF043;":"&#35;"
  , "&#xF044;":"&#916;"       # Capital Delta
  , "&#xF045;":"&#37;"
  , "&#xF046;":"&#38;"
  , "&#xF047;":"&#8717;"
  , "&#xF048;":"&#40;"        # U+0028 LEFT PARENTHESIS, UTF-8: 0x28
  , "&#xF049;":"&#41;"        # U+0029 RIGHT PARENTHESIS, UTF-8: 0x29
  , "&#xF04A;":"&#42;"        # U+002A ASTERISK, UTF-8: 0x2A
  , "&#xF04B;":"&#43;"        # U+002B PLUS SIGN, UTF-8: 0x2B
  , "&#xF04C;":"&#44;"        # U+002C COMMA, UTF-8: 0x2C
  , "&#xF04D;":"&#45;"        # U+002D HYPHEN-MINUS, UTF-8: 0x2D
  , "&#xF04E;":"&#46;"        # U+002E FULL STOP, UTF-8: 0x2E
  , "&#xF04F;":"&#47;"        # U+002F SOLIDUS, UTF-8: 0x2F
  , "&#xF050;":"&#48;"        # U+0030 DIGIT ZERO, UTF-8: 0x30
  , "&#xF051;":"&#49;"        # U+0031 DIGIT ONE, UTF-8: 0x31
  , "&#xF052;":"&#50;"        # U+0032 DIGIT TWO, UTF-8: 0x32
  , "&#xF053;":"&#51;"        # U+0033 DIGIT THREE, UTF-8: 0x33
  , "&#xF054;":"&#52;"        # U+0034 DIGIT FOUR, UTF-8: 0x34
  , "&#xF055;":"&#53;"        # U+0035 DIGIT FIVE, UTF-8: 0x35
  , "&#xF056;":"&#54;"        # U+0036 DIGIT SIX, UTF-8: 0x36
  , "&#xF057;":"&#55;"        # U+0037 DIGIT SEVEN, UTF-8: 0x37
  , "&#xF058;":"&#56;"        # U+0038 DIGIT EIGHT, UTF-8: 0x38
  , "&#xF059;":"&#57;"        # U+0039 DIGIT NINE, UTF-8: 0x39
  , "&#xF05A;":"&#58;"        # U+003A COLON, UTF-8: 0x3A
  , "&#xF05B;":"&#59;"        # U+003B SEMICOLONUTF-8: 0x3B
  , "&#xF05C;":"&#60;"        # U+003C LESS-THAN SIGN, UTF-8: 0x3C
  , "&#xF05D;":"&#61;"        # U+003D EQUALS SIGN, UTF-8: 0x3D
  , "&#xF05E;":"&#62;"        # U+003E GREATER-THAN SIGN, UTF-8: 0x3E
  , "&#xF05F;":"&#63;"        # U+003F QUESTION MARK, UTF-8: 0x3F
  , "&#xF060;":"&#8773;"
  , "&#xF061;":"&#913;"
  , "&#xF062;":"&#914;"
  , "&#xF063;":"&#935;"
  , "&#xF064;":"&#916;"
  , "&#xF065;":"&#917;"
  , "&#xF066;":"&#934;"
  , "&#xF067;":"&#915;"
  , "&#xF068;":"&#919;"
  , "&#xF069;":"&#921;"
  , "&#xF06A;":"&#920;"
  , "&#xF06B;":"&#922;"
  , "&#xF06C;":"&#923;"
  , "&#xF06D;":"&#924;"
  , "&#xF06E;":"&#925;"
  , "&#xF06F;":"&#927;"
  , "&#xF070;":"&#928;"
  , "&#xF071;":"&#920;"
  , "&#xF072;":"&#929;"
  , "&#xF073;":"&#931;"
  , "&#xF074;":"&#932;"
  , "&#xF075;":"&#933;"
  , "&#xF076;":"&#950;"
  , "&#xF077;":"&#937;"
  , "&#xF078;":"&#926;"
  , "&#xF079;":"&#936;"
  , "&#xF07A;":"&#918;"
  , "&#xF07B;":"&#91;"
  , "&#xF07C;":"&#8756;"
  , "&#xF07D;":"&#93;"
  , "&#xF07E;":"&#8869;"
  , "&#xF0A1;":"&#8364;"
  , "&#xF0A2;":"&#165;"
  , "&#xF0A3;":"&#180;"
  , "&#xF0A4;":"&#8804;"
  , "&#xF0A5;":"&#47;"
  , "&#xF0A6;":"&#8734;"
  , "&#xF0A8;":"&#9827;"
  , "&#xF0A9;":"&#9830;"
  , "&#xF0AA;":"&#9829;"
  , "&#xF0AB;":"&#9824;"
  , "&#xF0AC;":"&#8596;"
  , "&#xF0AD;":"&#8592;"
  , "&#xF0AE;":"&#8593;"
  , "&#xF0AF;":"&#8594;"
  , "&#xF0B0;":"&#8595;"
  , "&#xF0B1;":"&#176;"
  , "&#xF0B2;":"&#177;"
  , "&#xF0B3;":"&#34;"
  , "&#xF0B4;":"&#8805;"
  , "&#xF0B5;":"&#8770;"
  , "&#xF0B6;":"&#8733;"
  , "&#xF0B7;":"&#8706;"
  , "&#xF0B8;":"&#8729;"
  , "&#xF0B9;":"&#8771;"
  , "&#xF0BA;":"&#8800;"
  , "&#xF0BB;":"&#8801;"
  , "&#xF0BC;":"&#8776;"
  , "&#xF0BD;":"&#8943;"
  , "&#xF0BE;":"&#8739;"
  , "&#xF0BF;":"&#9472;"
  , "&#xF0C0;":"&#8629;"
  , "&#xF0C1;":"&#8501;"
  , "&#xF0C2;":"&#8503;"
  , "&#xF0C3;":"&#8476;"
  , "&#xF0C4;":"&#8472;"
  , "&#xF0C5;":"&#8855;"
  , "&#xF0C6;":"&#8853;"
  , "&#xF0C7;":"&#8856;"
  , "&#xF0C8;":"&#8745;"
  , "&#xF0C9;":"&#8746;"
  , "&#xF0CA;":"&#8835;"
  , "&#xF0CB;":"&#8839;"
  , "&#xF0CC;":"&#8836;"
  , "&#xF0CD;":"&#8834;"
  , "&#xF0CE;":"&#8838;"
  , "&#xF0CF;":"&#8714;"
  , "&#xF0D0;":"&#8713;"
  , "&#xF0D1;":"&#8711;"
  , "&#xF0D2;":"&#174;"
  , "&#xF0D3;":"&#169;"
  , "&#xF0D4;":"&#8482;"
  , "&#xF0D5;":"&#8719;"
  , "&#xF0D6;":"&#8730;"
  , "&#xF0D7;":"&#8729;"
  , "&#xF0D8;":"&#172;"
  , "&#xF0D9;":"&#8896;"
  , "&#xF0DA;":"&#8897;"
  , "&#xF0DB;":"&#8660;"
  , "&#xF0DC;":"&#8656;"
  , "&#xF0DD;":"&#8657;"
  , "&#xF0DE;":"&#8658;"
}


def replace(text):
  """Replace both the hex and decimal versions of symbols in an XML string"""
  for hex, value in UNICODE_DICTIONARY.items():
    num = int(hex[3:-1], 16)
    #uni = unichr(num)
    decimal = '&#' + str(num) + ';'
    for key in [ hex, decimal ]: #uni
      text = text.replace(key, value)
  return text
