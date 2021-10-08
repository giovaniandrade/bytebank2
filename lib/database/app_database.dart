import 'package:bytebank2/database/dao/contact_dao.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Future<Database> createDatabase() {
//   return getDatabasesPath().then((dbPath) {
//     final String path = join(dbPath, 'bytebank.db');
//     return openDatabase(
//       path,
//       onCreate: (db, version) {
//         db.execute('CREATE TABLE contacts('
//             'id INTEGER PRIMARY KEY, '
//             'name TEXT, '
//             'account_number INTEGER)');
//       },
//       version: 1,
//       // onDowngrade: onDatabaseDowngradeDelete, // quando aumenta depois diminui a versão, limpa o banco
//     );
//   });
// }

// Refatorando
Future<Database> getDatabase() async { // async transforma esse escopo num Future
  final String path = join(await getDatabasesPath(), 'bytebank.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        db.execute(ContactDao.tableSql);
      },
      version: 1,
    );
}


