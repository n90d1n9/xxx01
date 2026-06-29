import 'package:logger/logger.dart';

final prettyPrinter = PrettyPrinter(
  methodCount: 0,
  errorMethodCount: 5,
  lineLength: 50,
  colors: true,
  printEmojis: true,
  dateTimeFormat: DateTimeFormat.dateAndTime,
);

final logger = Logger(
  printer: prettyPrinter,
);
