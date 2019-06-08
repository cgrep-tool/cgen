import 'dart:io';
import 'package:args/args.dart';
import '../error.dart';

import 'append.dart';
import 'new_data.dart';

export 'append.dart';
export 'new_data.dart';

abstract class Options {
  Future<void> perform();

  factory Options.parse(List<String> args) {
    final parser = ArgParser()
      ..addOption('separator', abbr: 's', defaultsTo: ',')
      ..addOption('count', abbr: 'c')
      ..addOption('int')
      ..addOption('double')
      ..addOption('date')
      ..addOption('duration')
      ..addOption('bool')
      ..addOption('min');

    final result = parser.parse(args);
    final errMaker = Error(parser.usage);

    if (result.rest.length > 1) {
      stderr.writeln(errMaker.multipleInputs(result.rest));
      exit(2);
    }

    if(result.rest.isEmpty) {
      return NewDataOption.parse(result, errMaker);
    } else {
      return AppendOption.parse(result);
    }
  }
}
