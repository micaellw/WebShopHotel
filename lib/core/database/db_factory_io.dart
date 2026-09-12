import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initDatabaseFactory() async {
  try {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } catch (_) {}
}
