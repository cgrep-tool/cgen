import 'package:cgen/src/cmd/cmd.dart';

import 'src/executor/executor.dart';

Future<void> perform(List<String> args) async {
  await RootCmd().go(args);
}
