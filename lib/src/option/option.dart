import 'dart:io';
import 'package:args/args.dart';
import '../error.dart';

import 'append.dart';
import 'new_data.dart';

export 'append.dart';
export 'new_data.dart';

abstract class Options {
  Future<void> perform();

  static Future<Options> parse(List<String> args) async {
    final parser = ArgParser()
      ..addOption('separator', abbr: 's', defaultsTo: ',')
      ..addOption('count', abbr: 'c')
      ..addFlag('Int', abbr: 'I', defaultsTo: false)
      ..addFlag('Double', abbr: 'D', defaultsTo: false)
      ..addFlag('Date', abbr: 'T', defaultsTo: false)
      ..addFlag('Duration', abbr: 'U', defaultsTo: false)
      ..addFlag('Bool', abbr: 'B', defaultsTo: false)
      ..addOption('one-of', abbr: 'o')
      ..addOption('min', abbr: 'm')
      ..addOption('max', abbr: 'x');

    final result = parser.parse(args);
    final errMaker = ErrorMaker(parser.usage);

    if (result.rest.length > 1) {
      stderr.writeln(errMaker.multipleInputs(result.rest));
      exit(2);
    }

    if (result.rest.isEmpty) {
      return await NewDataOption.parse(result, errMaker);
    } else {
      return await AppendOption.parse(result, errMaker);
    }
  }
}
