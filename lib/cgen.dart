import 'src/option/option.dart';

Future<void> perform(List<String> args) async {
  final options = Options.parse(args);
  await options.perform();
}