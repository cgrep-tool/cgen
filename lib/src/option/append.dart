import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import '../range.dart';
import 'option.dart';
import '../error.dart';

class AppendOption implements Options {
  final ValueRange spec;

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

  static Future<AppendOption> parse(ArgResults result, ErrorMaker errMaker) async {
    if(result['count'] != null) {
      errMaker.usageWithError("Option 'count' is not compatible with append mode");
    }

    String separator = result['separator'];
    return AppendOption(result.rest[0], await ValueRange.parse(result, errMaker), separator);
  }
}