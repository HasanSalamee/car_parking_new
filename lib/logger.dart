import 'package:logging/logging.dart';

void initRootLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print(
        '${record.time}: ${record.loggerName}: ${record.level.name}:  ${record.message}');
  });
}

void exampleLogs(Logger logger) {
  print('example print');
  logger.finest('example finest log entry');
  logger.finer('example finer log entry');
  logger.fine('example fine log entry');
  logger.info('example info log entry');
  logger.warning('example warning log entry');
  logger.severe('example severe log entry');
  logger.shout('example shout log entry');
}
