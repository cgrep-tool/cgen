import 'dart:math';
import 'package:args/args.dart';
import 'package:duration/duration.dart';

abstract class ValueRange<T> {
  T next();

  static ValueRange parse(ArgResults result) {
    final list = <ValueRange>[];

    final minStr = result['min'];

    if (result['int'] != null) {
      int min = int.tryParse(minStr);
      int max = int.tryParse(result['int']);
      list.add(IntRange(min, max));
    }
    if (result['double'] != null) {
      double min = double.tryParse(minStr);
      double max = double.tryParse(result['double']);
      list.add(DoubleRange(min, max));
    }
    if (result['date'] != null) {
      DateTime min = DateTime.tryParse(minStr);
      DateTime max = DateTime.tryParse(result['date']);
      list.add(DateTimeRange(min, max));
    }
    if (result['duration'] != null) {
      Duration min = parseDuration(minStr);
      Duration max = parseDuration(result['duration']);
      list.add(DurationRange(min, max));
    }

    if (list.length > 1) {
      throw UnsupportedError("Multiple types are not supported");
    }

    return list.isNotEmpty ? list.first : null;
  }
}

class IntRange implements ValueRange<int> {
  final int min;

  final int max;

  Random _random = Random();

  IntRange(this.min, this.max);

  int next() {
    return _random.nextInt(max - min) + min;
  }
}

class DoubleRange implements ValueRange<double> {
  final double min;

  final double max;

  Random _random = Random();

  DoubleRange(this.min, this.max);

  double next() {
    return (_random.nextDouble() * (max - min)) + min;
  }
}

class BoolRange implements ValueRange<bool> {
  Random _random = Random();

  BoolRange();

  bool next() {
    return _random.nextBool();
  }
}

class DateTimeRange implements ValueRange<DateTime> {
  final DateTime min;

  final DateTime max;

  Random _random = Random();

  DateTimeRange(this.min, this.max);

  DateTime next() {
    int us = _random.nextInt(max.difference(min).inMicroseconds);
    return min.add(Duration(microseconds: us));
  }
}

class DurationRange implements ValueRange<Duration> {
  final Duration min;

  final Duration max;

  Random _random = Random();

  DurationRange(this.min, this.max);

  Duration next() {
    int us = _random.nextInt((max - min).inMicroseconds);
    return min + Duration(microseconds: us);
  }
}