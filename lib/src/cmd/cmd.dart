import 'package:args/args.dart';
import 'package:cgen/src/option/option.dart';
import 'package:random_data/random_data.dart';

abstract class CustomCmd<T> {
  ArgParser build();

  T parse(ArgResults result);
}

class IntCmd implements CustomCmd {
  ArgParser build() {
    final cmd = ArgParser();

    cmd
      ..addOption('min',
          abbr: 'm',
          help: 'Provides minimum limit of the randomly generated int column.',
          valueHelp: '10')
      ..addOption('max',
          abbr: 'x',
          help: 'Provides maximum limit of the randomly generated int column.',
          valueHelp: '100');

    return cmd;
  }

  Generator parse(ArgResults result) {
    // TODO
  }

  static final instance = IntCmd();
}

class DoubleCmd implements CustomCmd {
  ArgParser build() {
    final cmd = ArgParser();

    cmd
      ..addOption('min',
          abbr: 'm',
          help:
              'Provides minimum limit of the randomly generated floating point column.',
          valueHelp: '10')
      ..addOption('max',
          abbr: 'x',
          help:
              'Provides maximum limit of the randomly floating point generated column.');

    return cmd;
  }

  Generator parse(ArgResults result) {
    // TODO
  }

  static final instance = DoubleCmd();
}

class RootCmd implements CustomCmd {
  ArgParser build() {
    final parser = ArgParser();

    parser
      ..addOption('delimiter',
          abbr: 'd',
          defaultsTo: ',',
          help:
              'Specifies the column separator for the input and output files.',
          valueHelp: r'\t')
      ..addOption('seed',
          abbr: 's',
          help: ('Seed for random number generator'),
          valueHelp: '555')
      ..addOption('count',
          abbr: 'c',
          help:
              'For new output file mode, specifies number of rows of random values to generate.',
          valueHelp: '100');

    parser.addCommand('int', IntCmd.instance.build());
    parser.addCommand('int', DoubleCmd.instance.build());

    return parser;
  }

  @override
  Options parse(ArgResults result) {
    Generator gen;
    if (result.command.name == 'int') {
      gen = IntCmd.instance.parse(result);
    } else if (result.command.name == 'double') {
      gen = DoubleCmd.instance.parse(result);
    }
    // TODO
  }

  Future<void> go(List<String> args) async {
    final parser = build();

    final result = parser.parse(args);

    final options = parse(result);

    await options.perform();
  }
}
