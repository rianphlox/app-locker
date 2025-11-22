import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class LogService {
  static late final Logger _logger;
  static late final File _logFile;

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/app.log');

    _logger = Logger(
      printer: PrettyPrinter(),
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(file: _logFile),
      ]),
    );
  }

  static Logger get logger => _logger;
}
