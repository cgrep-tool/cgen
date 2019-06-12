import 'dart:io';
import 'executor.dart';

class NewDataOption implements Executor {
  final WithFormatter spec;

  final int count;

  NewDataOption(this.spec, this.count);

  Future<void> perform() async {
    for (int i = 0; i < count; i++) {
      dynamic v = spec.next();
      stdout.writeln(v);
    }
  }
}
