// TODO: Put public facing types in this file.

import 'dart:io';
import 'dart:isolate';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:stack_trace/stack_trace.dart';

class SfoLogConfig {
  String logLevel = "info";
  String logFilePath;
  bool outputToConsole = true;
  bool outputToFile = true;
  String appName;

  SfoLogConfig(this.appName, {this.logLevel = "info", String? logFilePath, this.outputToConsole = true, this.outputToFile = true}) : logFilePath = logFilePath ?? "${Directory.current.path}/logs/";
}

class _SfoLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    var level;
    switch (event.level) {
      case Level.trace:
        level = "TRACE";
      case Level.info:
        level = "INFO";
      case Level.warning:
        level = "WARN";
      case Level.error:
        level = "ERROR";
      default:
        level = "UNKNOWN";
    }
    if (event.stackTrace != null && event.stackTrace is Chain) {
      var chain = event.stackTrace as Chain;
      var frame = chain.toTrace().frames[1];
      return ["${DateFormat('yyyy-MM-dd HH:mm:ss').format(event.time)} [$level] [${frame.library}:${frame.line}] [${Isolate.current.hashCode}] ${event.message}"];
    } else {
      return ["${DateFormat('yyyy-MM-dd HH:mm:ss').format(event.time)} [$level] [${Isolate.current.hashCode}] ${event.message}"];
    }

  }

}

class SfoLog {
  static late Logger logger;
  static bool log = false;

  static void init(SfoLogConfig config) {
    if (!config.outputToConsole && !config.outputToFile) {
      return;
    }
    log = true;
    var filter = DevelopmentFilter();
    if (config.logLevel == "trace") {
      filter.level = Level.trace;
    } else if (config.logLevel == "debug") {
      filter.level = Level.debug;
    } else if (config.logLevel == "info") {
      filter.level = Level.info;
    } else if (config.logLevel == "warning") {
      filter.level = Level.warning;
    } else if (config.logLevel == "error") {
      filter.level = Level.error;
    }
    logger = Logger(
      filter: DevelopmentFilter(),  // 开发环境过滤器
      printer: _SfoLogPrinter(),
      output: MultiOutput([
        ConsoleOutput(),           // 默认控制台输出
        AdvancedFileOutput(maxFileSizeKB: 10240, maxRotatedFilesCount: 10, path: config.logFilePath, latestFileName: "${config.appName}_rCURRENT.log"),              // 自定义文件输出
      ]),
      level: filter.level,           // 日志级别
    );
  }

  static void d(
      dynamic message, {
        DateTime? time,
        Object? error,
      }) {
    if (!log) return;
    logger.d(message, time: time, error: error, stackTrace: Chain.current());
  }

  static void i(
      dynamic message, {
        DateTime? time,
        Object? error,
      }) {
    if (!log) return;
    logger.i(message, time: time, error: error, stackTrace: Chain.current());
  }

  static void w(
      dynamic message, {
        DateTime? time,
        Object? error,
      }) {
    if (!log) return;
    logger.w(message, time: time, error: error, stackTrace: Chain.current());
  }

  static void e(
      dynamic message, {
        DateTime? time,
        Object? error,
      }) {
    if (!log) return;
    logger.e(message, time: time, error: error, stackTrace: Chain.current());
  }

  static void t(
      dynamic message, {
        DateTime? time,
        Object? error,
      }) {
    if (!log) return;
    logger.t(message, time: time, error: error, stackTrace: Chain.current());
  }
}
