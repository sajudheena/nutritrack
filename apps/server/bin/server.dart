import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:args/args.dart';
import 'package:server/server.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('db', abbr: 'd', defaultsTo: '');

  final results = parser.parse(arguments);
  final port = int.parse(results['port'] as String);

  // Always store the DB next to the server binary, regardless of working directory
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  final dbPath = (results['db'] as String).isNotEmpty
      ? results['db'] as String
      : '$scriptDir\\nutritrack.db';

  final dbService = DbService(dbPath: dbPath);
  dbService.initialize();

  final jwtService = JwtService();
  final router = buildRouter(dbService: dbService, jwtService: jwtService);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('NutriTrack server listening on http://${server.address.host}:${server.port}');
}
