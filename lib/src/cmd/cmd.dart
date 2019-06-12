import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cgen/src/cmd/bool.dart';
import 'package:cgen/src/executor/executor.dart';

import 'float.dart';
import 'int.dart';

export 'float.dart';
export 'int.dart';

abstract class CustomCmd<T> {
  ArgParser build();

  WithFormatter parse(ArgParser parser, ArgResults result);
}

class RootCmd {
  CommandRunner _runner;

  Future<void> go(List<String> args) async {
    _runner = CommandRunner('cgen',
        'Generates random columns to be added to delimiter-seperated value file.');

    _runner.addCommand(IntCommand());
    _runner.addCommand(FloatCommand());
    _runner.addCommand(BoolCommand());

    try {
      await _runner.run(args);
    } on ArgException catch (e) {
      writeUsageException(e);
      exit(2);
    } on FormatException catch (e) {
      writeUsageException(ArgException(_runner.argParser, e.message));
      exit(2);
    } on UsageException catch (e) {
      stderr.writeln(e.message);
      stderr.writeln();
      stderr.writeln(e.usage);
      exit(2);
    }
  }

  void writeUsageException(ArgException e) {
    stderr.write(e.error());
  }
}

void addCommonOptions(ArgParser parser) {
  parser
    ..addSeparator('Common options:')
    ..addOption('delimiter',
        abbr: 'd',
        defaultsTo: ',',
        help: 'Specifies the column separator for the input and output files.',
        valueHelp: r'\t')
    ..addOption('seed',
        abbr: 's', help: ('Seed for random number generator'), valueHelp: '555')
    ..addOption('count',
        abbr: 'c',
        help:
            'For new output file mode, specifies number of rows of random values to generate.',
        valueHelp: '100');
}

Random makeRandom(ArgParser parser, ArgResults result) {
  Random random = Random();
  String seedStr = result['seed'];
  int seed;
  if (seedStr != null) {
    seed = int.tryParse(seedStr);
    if (seed == null) {
      throw ArgException(parser, 'Seed shall be an integer');
    }
  }
  random = Random(seed);
  return random;
}

Future<Executor> makeExecutor(
    ArgParser parser, ArgResults result, WithFormatter gen) async {
  if (result.rest.length > 1) {
    throw ArgException.multipleInputs(parser, result.rest);
  }

  if (result.rest.isEmpty) {
    int count;
    String countStr = result['count'];
    if (countStr == null) {
      throw ArgException(
          parser, '"Count is mandatory if input file is not specified"');
    }
    count = int.tryParse(countStr);
    if (count == null) {
      throw ArgException(parser, "Specified count $count is not a number");
    }

    return await NewDataOption(gen, count);
  } else {
    if (result['count'] != null) {
      throw ArgException(
          parser, "Option 'count' is not compatible with append mode");
    }

    String separator = result['separator'];

    return await AppendOption(result.rest.first, gen, separator);
  }
}

class ArgException {
  final ArgParser parser;

  final String msg;

  ArgException(this.parser, this.msg);

  factory ArgException.multipleInputs(ArgParser parser, List<String> files) {
    return ArgException(
        parser, "Multiple input files not supported yet: $files!");
  }

  String error() {
    final sb = StringBuffer();

    sb.writeln(msg);
    sb.writeln();
    sb.writeln(parser.usage);

    return sb.toString();
  }
}
