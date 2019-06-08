import 'package:args/args.dart';

class Error {
  final String usage;

  Error(this.usage);

  String multipleInputs(List<String> files) {
    return usageWithError("Multiple input files not supported yet: $files!");
  }

  String countNotFound() {
    return usageWithError("Count is mandatory if input file is not specified");
  }

  String countNotNumber(String count) {
    return usageWithError("Specified count $count is not a number");
  }

  String usageWithError(String error) {
    return "$error\r\n$usage";
  }
}