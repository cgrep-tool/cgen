class ErrorMaker {
  final String usage;

  ErrorMaker(this.usage);

  String multipleInputs(List<String> files) {
    return printError("Multiple input files not supported yet: $files!");
  }

  String countNotFound() {
    return printError("Count is mandatory if input file is not specified");
  }

  String countNotNumber(String count) {
    return printError("Specified count $count is not a number");
  }

  String multipleTypes(List<String> types) {
    return printError(
        "Only one column type definition allowed. Multiple provided: ${types}!");
  }

  String printError(String error) {
    return "$error\r\n$usage";
  }
}
