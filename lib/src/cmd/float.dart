import 'package:args/command_runner.dart';
import 'package:cgen/src/executor/executor.dart';
import 'package:random_data/random_data.dart';
import 'cmd.dart';

class FloatCommand extends Command {
  @override
  String get name => "float";

  @override
  String get description => 'Generates random floating point.';


  @override
  final aliases = ['double'];

  FloatCommand() {
    argParser
      ..addOption('min',
          abbr: 'm',
          help:
              'Minimum limit of the randomly generated floating point column.',
          valueHelp: '10')
      ..addOption('max',
          abbr: 'x',
          help:
              'Maximum limit of the randomly generated floating point column.')
      ..addOption('max-precision',
          abbr: 'p',
          defaultsTo: '2',
          help:
              'Maximum number of digits after decimal point in generated floating point numbers.');

    addCommonOptions(argParser);
  }

  @override
  Future<void> run() async {
    final random = makeRandom(argParser, argResults);

    String minStr = argResults['min'];
    String maxStr = argResults['max'];
    String maxPrecisionStr = argResults['max-precision'];

    double min = double.tryParse(minStr ?? '');
    double max = double.tryParse(maxStr ?? '');
    int maxPrecision = int.tryParse(maxPrecisionStr);

    if (minStr != null && min == null) {
      throw UsageException(
          'Invalid "--min" option provided. Must be floating point number!',
          usage);
    }

    if (maxStr != null && max == null) {
      throw UsageException(
          'Invalid "--max" option provided. Must be floating point number!',
          usage);
    }

    if (maxPrecisionStr != null && maxPrecision == null) {
      throw UsageException(
          'Invalid "--max-precision" option provided. Must be a positive integer!',
          usage);
    }
    if (maxPrecision != null && maxPrecision.isNegative) {
      throw UsageException(
          'Invalid "--max-precision" option provided. Must be a positive integer!',
          usage);
    }

    maxPrecision ??= 2;

    final exe = await makeExecutor(
        argParser,
        argResults,
        WithFormatter(
            DoubleGen(min, max, maxPrecision: maxPrecision, random: random)));
    await exe.perform();
  }
}