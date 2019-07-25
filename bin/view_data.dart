import 'dart:io';

main(List<String> args) async {
  final pubGetProcess = await Process.start('pub', ['get'], workingDirectory: 'benchmark/dart2js_info', mode: ProcessStartMode.inheritStdio);
  await pubGetProcess.exitCode.then(_handleExitCode);

  final webDevServeProcess = await Process.start('webdev', ['serve'], workingDirectory: 'benchmark/dart2js_info', mode: ProcessStartMode.inheritStdio);
  await webDevServeProcess.exitCode.then(_handleExitCode);
}

void _handleExitCode(int code) {
  if (code != 0) {
    exit(code);
  }
}
