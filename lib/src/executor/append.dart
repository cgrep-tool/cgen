import 'dart:io';
import 'dart:convert';
import 'executor.dart';

class AppendOption implements Executor {
  final WithFormatter spec;

  final String separator;

  final String filename;

  AppendOption(this.filename, this.spec, this.separator);

  Future<void> perform() async {
    Stream<List<int>> input;
    if (filename == '-') {
      input = stdin;
    } else {
      final file = File(filename);
      // Check if file exists
      if (!await file.exists()) {
        stderr.writeln("Input file $filename does not exist!");
        exit(2);
      }
      input = await file.openRead();
    }

    final lines = input.transform(utf8.decoder).transform(LineSplitter());

    await for (String line in lines) {
      dynamic v = spec.next();
      stdout.writeln("$line$separator$v");
    }
  }
}
