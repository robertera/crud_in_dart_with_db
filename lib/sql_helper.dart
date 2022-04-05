import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE pessoas(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      nome TEXT,
      email TEXT,
      telefone TEXT,
      idade TEXT
    )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'crud.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  //cadastrar pessoa
  static Future<int> cadastrarPessoa(String nome, String email, String telefone, String idade) async {
    final db = await SQLHelper.db();

    final data = {'nome': nome, 'email': email, 'telefone': telefone, 'idade': idade};
    final id = await db.insert('pessoas', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //listar pessoa
  static Future<List<Map<String, dynamic>>> getPessoas() async {
    final db = await SQLHelper.db();
    return db.query('pessoas', orderBy: "id");
  }

  //modificar pessoa
  static Future<int> atualizarPessoa(int id, String nome, String email, String telefone, String idade) async {
    final db = await SQLHelper.db();

    final data = {'nome': nome, 'email': email, 'telefone': telefone, 'idade': idade.toString()};

    final result = await db.update('pessoas', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  //deletar pessoa
  static Future<void> deletarPessoa(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("pessoas", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Algo inesperado aconteceu ao excluir o cadastro: $err");
    }
  }
}
