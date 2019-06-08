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

  static NewDataOption parse(ArgResults result, Error errMaker) {
    int count;
    if (result['count'] == null) {
      stderr.writeln(errMaker.countNotFound());
      exit(2);
    }
    count = int.tryParse(result['count']);
    if (count == null) {
      stderr.writeln(errMaker.countNotNumber(result['count']));
      exit(2);
    }
    return NewDataOption(ValueRange.parse(result), count);
  }
}