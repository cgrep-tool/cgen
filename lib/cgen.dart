import 'src/option/option.dart';

Future<void> perform(List<String> args) async {
  final options = await Options.parse(args);
  await options.perform();
}
