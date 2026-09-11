import 'package:chinese_study/data/tsv_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses plain word\\tdefinition lines', () {
    final words = parseTsv('你好\thello\n谢谢\tthank you\n');
    expect(words.length, 2);
    expect(words[0].hanzi, '你好');
    expect(words[0].definition, 'hello');
  });

  test('parses index\\t"word"\\t"definition" lines and strips quotes', () {
    final words = parseTsv('1\t"变化"\t"change; to change"\n2\t"末"\t"end"\n');
    expect(words.length, 2);
    expect(words[0].hanzi, '变化');
    expect(words[0].definition, 'change; to change');
    expect(words[1].hanzi, '末');
    expect(words[1].definition, 'end');
  });

  test('skips a header row', () {
    final words = parseTsv('word\tdefinition\n你好\thello\n');
    expect(words.length, 1);
    expect(words[0].hanzi, '你好');
  });

  test('skips blank lines', () {
    final words = parseTsv('你好\thello\n\n\n谢谢\tthank you\n');
    expect(words.length, 2);
  });
}
