import 'package:args/command_runner.dart';
import 'package:cgen/src/executor/executor.dart';
import 'package:random_data/random_data.dart';
import 'cmd.dart';

class IntCommand extends Command {
  @override
  String get name => "int";

  @override
  String get description => 'Generates random integers.';

  IntCommand() {
    argParser
      ..addOption('min',
          abbr: 'm',
          help: 'Provides minimum limit of the randomly generated int column.',
          valueHelp: '10')
      ..addOption('max',
          abbr: 'x',
          help: 'Provides maximum limit of the randomly generated int column.',
          valueHelp: '100');

    addCommonOptions(argParser);
  }

  @override
  Future<void> run() async {
    final random = makeRandom(argParser, argResults);

    String minStr = argResults['min'];
    String maxStr = argResults['max'];

    int min = int.tryParse(minStr ?? '');
    int max = int.tryParse(maxStr ?? '');

    if(minStr != null && min == null) {
      throw UsageException('Invalid "--min" option provided. Must be integer!', usage);
    }

    if(maxStr != null && max == null) {
      throw UsageException('Invalid "--max" option provided. Must be integer!', usage);
    }

    final exe = await makeExecutor(argParser, argResults,
        WithFormatter(IntGen(min, max, random: random)));
    await exe.perform();
  }
}
