import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:duration/duration.dart';
import 'error.dart';
import 'package:random_data/random_data.dart';
import 'package:random_string/random_string.dart';

abstract class Gen<T> {
  T next();

  String get type;

  bool get isMinLessThanEqualMax;

  static Future<Generator> parse(ArgResults result, ErrorMaker errMaker) async {
    final list = <Generator>[];

    Random random = Random();
    {
      String seedStr = result['seed'];
      int seed;
      if (seedStr != null) {
        seed = int.tryParse(seedStr);
        if (seed == null) {
          errMaker.printError("Seed must be an integer!");
          exit(1);
        }
      }
      random = Random(seed);
    }

    String minStr = result['min'];
    String maxStr = result['max'];

    if (result['Int']) {
      int min = int.tryParse(minStr ?? '');
      int max = int.tryParse(maxStr ?? '');
      list.add(IntGen(min, max, random: random));
    }
    if (result['Double']) {
      double min = double.tryParse(minStr ?? '');
      double max = double.tryParse(maxStr ?? '');
      list.add(DoubleGen(min, max, random: random));
    }
    if (result['Date']) {
      DateTime min = DateTime.now();
      if (minStr != null) {
        final temp = DateTime.tryParse(minStr);
        if (temp != null) min = temp;
      }
      DateTime max = min.add(Duration(days: 365 * 5));
      if (maxStr != null) {
        final temp = DateTime.tryParse(maxStr);
        if (temp != null) max = temp;
      }
      list.add(DateTimeGen(min.toUtc(), max.toUtc(), random: random));
    }
    if (result['Duration']) {
      Duration min = Duration();
      if (minStr != null) min = tryParseDurationAny(minStr);
      Duration max = Duration(days: 365);
      if (maxStr != null) max = tryParseDurationAny(maxStr);
      list.add(DurationGen(min, max, random: random));
    }
    if (result['file'] != null) {
      final file = File(result['file']);
      if (!await file.exists()) {
        errMaker.printError("File ${result['file']} foes not exist!");
        exit(1);
      }
      final options = await file
          .openRead()
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .toList();
      list.add(OneOfGen(options, random: random));
    }
    if (result['list'] != null) {
      final options = (result['list'] as String).split("|").toList();
      list.add(OneOfGen(options, random: random));
    }
    if (result['char']) {
      if (result['alpha']) {
        list.add(CharGen.alpha(random: random));
      } else if (result['numeric']) {
        list.add(CharGen.numeric(random: random));
      } else if (result['alpha-numeric']) {
        list.add(CharGen.alphaNumeric(random: random));
      } else {
        if (result['range'] == null) {
          stderr.writeln(errMaker.printError(
              "No char spec provided. Try 'range', 'alpha', 'numeric' or 'alpha-numeric'."));
          exit(2);
        }
        CharRanges charSpec;
        try {
          charSpec = CharRanges.fromSpec(result['range']);
        } on FormatException catch (e) {
          stderr.writeln(errMaker.printError("Char spec ${e.message}"));
          exit(2);
        }
        list.add(CharGen(charSpec, random: random));
      }
    }

    if (list.isEmpty) {
      stderr.writeln(errMaker.printError("No column type defintion provided"));
      exit(2);
    }

    if (list.length > 1) {
      stderr.writeln(errMaker.multipleTypes(list.map((v) => v.type).toList()));
      exit(2);
    }

    final ret = list.isNotEmpty ? list.first : null;

    if (!ret.isMinLessThanEqualMax) {
      errMaker.printError("Min cannot be greather than Max!");
      exit(1);
    }

    return ret;
  }
}
