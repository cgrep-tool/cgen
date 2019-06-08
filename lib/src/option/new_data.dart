import 'dart:io';
import 'package:args/args.dart';
import '../range.dart';
import '../error.dart';
import 'option.dart';

class NewDataOption implements Options {
  final ValueRange spec;

  final int count;

  NewDataOption(this.spec, this.count);

  Future<void> perform() async {
    for (int i = 0; i < count; i++) {
      dynamic v = spec.next();
      stdout.writeln(v);
    }
  }

  static Future<NewDataOption> parse(ArgResults result, ErrorMaker errMaker) async {
    int count;
    String countStr = result['count'];
    if (countStr == null) {
      stderr.writeln(errMaker.countNotFound());
      exit(2);
    }
    count = int.tryParse(countStr);
    if (count == null) {
      stderr.writeln(errMaker.countNotNumber(countStr));
      exit(2);
    }
    return NewDataOption(await ValueRange.parse(result, errMaker), count);
  }
}