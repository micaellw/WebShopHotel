import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initDatabaseFactory() async {
  try {
    databaseFactory = databaseFactoryFfiWeb;
  } catch (_) {
    try {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
    } catch (_) {}
  }
}
