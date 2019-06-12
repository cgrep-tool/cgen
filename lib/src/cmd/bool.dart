import 'package:args/command_runner.dart';
import 'package:cgen/src/executor/executor.dart';
import 'package:random_data/random_data.dart';
import 'cmd.dart';

class BoolCommand extends Command {
  @override
  String get name => "bool";

  @override
  String get description => 'Generates random integers.';

  BoolCommand() {
    argParser
      ..addOption(
        "format",
        abbr: 'o',
        defaultsTo: 'true|false',
        help: "True and false values of the generated values.",
      );

    addCommonOptions(argParser);
  }

  @override
  Future<void> run() async {
    final random = makeRandom(argParser, argResults);

    String formatStr = argResults['format'];
    final parts = formatStr.split("|");
    if (parts.length != 2) {
      throw UsageException("Invalid format option provided!", usage);
    }

    final exe = await makeExecutor(
        argParser,
        argResults,
        WithFormatter(BoolGen(random),
            formatter: _boolFormatter(parts[0], parts[1])));
    await exe.perform();
  }
}

Formatter _boolFormatter(String t, String f) {
  return (v) => v ? t : f;
}
