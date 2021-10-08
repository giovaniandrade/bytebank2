import 'package:bytebank2/database/app_database.dart';
import 'package:bytebank2/models/contact.dart';
import 'package:sqflite/sqflite.dart';

class ContactDao {

  // const e final são  constantes, mas para tipos primivos const tem uma performance melhor
  static const String tableSql = 'CREATE TABLE $_tableName('
      '$_id INTEGER PRIMARY KEY, '
      '$_name TEXT, '
      '$_accountNumber INTEGER)';
  static const String _tableName = 'contacts';
  static const String _id = 'id';
  static const String _name = 'name';
  static const String _accountNumber = 'account_number';

// Future<int> save(Contact contact) {
//   return getDatabase().then((db) {
//     final Map<String, dynamic> contacMap = Map();
//     // contacMap['id'] = contact.id; o Sqlite incrementa sozinho
//     contacMap['name'] = contact.name;
//     contacMap['account_number'] = contact.accountNumber;
//     return db.insert('contacts', contacMap);
//   });
// }

// Refatorando
  Future<int> save(Contact contact) async {
    final Database db = await getDatabase();
    Map<String, dynamic> contacMap = _toMap(contact);
    return db.insert(_tableName, contacMap);
  }

  Map<String, dynamic> _toMap(Contact contact) {
    final Map<String, dynamic> contacMap = {};
    contacMap[_name] = contact.name;
    contacMap[_accountNumber] = contact.accountNumber;
    return contacMap;
  }

  // Future<List<Contact>> findAll() {
//   return getDatabase().then((db) {
//     return db.query('contacts').then((maps) {
//       final List<Contact> contacts = [];
//       for (Map<String, dynamic> map in maps) {
//         final Contact contact = Contact(
//           map['id'],
//           map['name'],
//           map['account_number'],
//         );
//         contacts.add(contact);
//       }
//       return contacts;
//     });
//   });
// }

// Refatorando
  Future<List<Contact>> findAll() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    List<Contact> contacts = _toList(result);
    return contacts;
  }

  Future<int> update(Contact contact) async {
    final Database db = await getDatabase();
    final Map<String, dynamic> contactMap = _toMap(contact);
    return db.update(
      _tableName,
      contactMap,
      where: '$_id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = await getDatabase();
    return db.delete(
      _tableName,
      where: '$_id = ?',
      whereArgs: [id],
    );
  }

  List<Contact> _toList(List<Map<String, dynamic>> result) {
    final List<Contact> contacts = [];
    for (Map<String, dynamic> row in result) {
      final Contact contact = Contact(
        row[_id],
        row[_name],
        row[_accountNumber],
      );
      contacts.add(contact);
    }
    return contacts;
  }
}