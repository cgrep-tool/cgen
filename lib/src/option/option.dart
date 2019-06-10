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
      ..addOption('delimiter',
          abbr: 'd',
          defaultsTo: ',',
          help:
              'Specifies the column separator for the input and output files.',
          valueHelp: r'\t')
      ..addOption('seed', abbr: 's', help: ('Seed for random number generator'), valueHelp: '555')
      ..addOption('count',
          abbr: 'c',
          help:
              'For new output file mode, specifies number of rows of random values to generate.',
          valueHelp: '100')
      ..addFlag(
        'Int',
        abbr: 'I',
        defaultsTo: false,
        help:
            'Command to generate random integers. Use max and min options to specify minimum and maximum limits of random integers generated.',
      )
      ..addFlag(
        'Double',
        abbr: 'D',
        defaultsTo: false,
        help:
            'Command to generate random floating point numbers. Use max and min options to specify minimum and maximum limits of random floating point numbers generated.',
      )
      ..addFlag(
        'Date',
        abbr: 'T',
        defaultsTo: false,
        help:
            'Command to generate random date values. Use max and min options to specify minimum and maximum limits of random date values generated.',
      )
      ..addFlag(
        'Duration',
        abbr: 'U',
        defaultsTo: false,
        help:
            'Command to generate random duration values. Use max and min options to specify minimum and maximum limits of random duration values generated.',
      )
      ..addFlag('Bool', abbr: 'B', defaultsTo: false)
      ..addOption('file',
          abbr: 'f',
          help: 'Generated column values from the lines of provided file.',
          valueHelp: 'names.csv')
      ..addOption('list',
          abbr: 'l',
          help:
              'Generated column values from the list of provided values. Use pipe character (|) to separate values.',
          valueHelp: 'one|two|three|four')
      ..addOption('min',
          abbr: 'm',
          help: 'Provides minimum limit of the randomly generated column.',
          valueHelp: '10')
      ..addOption('max',
          abbr: 'x',
          help: 'Provides maximum limit of the randomly generated column.');

    // TODO parser.addCommand(name);

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
