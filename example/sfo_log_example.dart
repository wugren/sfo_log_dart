import 'package:sfo_log/sfo_log.dart';

void main() {
  SfoLog.init(SfoLogConfig("test"));
  SfoLog.i('Hello world!');
}
