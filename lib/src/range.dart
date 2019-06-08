import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:duration/duration.dart';
import 'error.dart';

abstract class ValueRange<T> {
  T next();

  String get type;

  static Future<ValueRange> parse(
      ArgResults result, ErrorMaker errMaker) async {
    final list = <ValueRange>[];

    String minStr = result['min'];
    String maxStr = result['max'];

    if (result['Int']) {
      int min = int.tryParse(minStr ?? '');
      int max = int.tryParse(maxStr ?? '');
      list.add(IntRange(min, max));
    }
    if (result['Double']) {
      double min = double.tryParse(minStr ?? '');
      double max = double.tryParse(maxStr ?? '');
      list.add(DoubleRange(min, max));
    }
    if (result['Date']) {
      DateTime min = DateTime.tryParse(minStr);
      DateTime max = DateTime.tryParse(result['date']);
      list.add(DateTimeRange(min, max));
    }
    if (result['Duration']) {
      Duration min = Duration();
      if(minStr != null) min = tryParseDurationAny(minStr);
      Duration max = Duration(days: 365);
      if(maxStr != null) max = tryParseDurationAny(maxStr);
      list.add(DurationRange(min, max));
    }
    if (result['one-of'] != null) {
      final file = File(result['one-of']);
      if (!await file.exists()) {
        // TODO
      }
      final options = await file
          .openRead()
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .toList();
      list.add(OneOf(options));
    }

    if (list.isEmpty) {
      stderr.writeln(
          errMaker.usageWithError("No column type defintion provided"));
      exit(2);
    }

    if (list.length > 1) {
      stderr.writeln(errMaker.multipleTypes(list.map((v) => v.type).toList()));
      exit(2);
    }

    return list.isNotEmpty ? list.first : null;
  }
}

final int intMin = -pow(2, 63);

final int intMax = (-pow(2, 63)) - 1;

class IntRange implements ValueRange<int> {
  final int min;

  final int max;

  Random _random = Random();

  IntRange._(this.min, this.max);

  factory IntRange(int min, int max) {
    return IntRange._(min ?? 0, max ?? pow(2, 32));
  }

  int next() {
    double diff = max.toDouble() - min.toDouble();
    if (diff <= pow(2, 32)) {
      return _random.nextInt(diff.toInt()) + min;
    }
    double d = _random.nextDouble();
    return ((d * diff) + min).toInt();
  }

  @override
  String get type => 'Int';
}

class DoubleRange implements ValueRange<double> {
  final double min;

  final double max;

  Random _random = Random();

  DoubleRange(this.min, this.max);

  double next() {
    return (_random.nextDouble() * (max - min)) + min;
  }

  @override
  String get type => 'Double';
}

class BoolRange implements ValueRange<bool> {
  Random _random = Random();

  BoolRange();

  bool next() {
    return _random.nextBool();
  }

  @override
  String get type => 'Bool';
}

class DateTimeRange implements ValueRange<DateTime> {
  final DateTime min;

  final DateTime max;

  IntRange _internal;

  DateTimeRange(this.min, this.max) {
    _internal =
        IntRange(min.microsecondsSinceEpoch, max.microsecondsSinceEpoch);
  }

  DateTime next() {
    return min.add(Duration(microseconds: _internal.next()));
  }

  @override
  String get type => 'Date';
}

class DurationRange implements ValueRange<Duration> {
  final Duration min;

  final Duration max;

  IntRange _internal;

  DurationRange(this.min, this.max) {
    _internal = IntRange(min.inMicroseconds, max.inMicroseconds);
  }

  Duration next() {
    return min + Duration(microseconds: _internal.next());
  }

  @override
  String get type => 'Duration';
}

class OneOf implements ValueRange<String> {
  final List<String> options;

  IntRange _internal;

  OneOf(this.options) {
    _internal = IntRange(0, options.length - 1);
  }

  @override
  String next() {
    return options[_internal.next()];
  }

  @override
  String get type => 'String';
}
