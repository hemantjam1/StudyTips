import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final databaseName = 'studyTipsDatabase.db';
  static final databaseVersion = 1;

  static final categoryTableName = 'categoryTable';
  static final categoryColumnId = 'categoryId';
  static final categoryColumnName = 'categoryName';
  static final categoryImageUrl = 'imageUrl';
  static final categoryLength = 'categoryLength';
  static final categoryInitialStudyTip = 'initialStudyTip';

  static final studyTipsTableName = 'studyTipsTable';
  static final categoryId = 'categoryId';
  static final studyTipsColumnId = 'studyTipsId';
  static final studyTipsColumn = 'studyTip';
  static final isFav = 'isFav';

  static late Database database;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get getDatabase async {
    database = await _initDatabase();
    return database;
  }

  static _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, databaseName);
    return openDatabase(path,
        version: databaseVersion,
        onCreate: _onCreate,
        onConfigure: _onConfigure);
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future _onCreate(Database database, int version) async {
    await database.execute('''CREATE TABLE $categoryTableName
   (
   $categoryColumnId INTEGER,
   $categoryColumnName TEXT NOT NULL,
   $categoryImageUrl TEXT NOT NULL,
   $categoryLength TEXT NOT NULL,
   $categoryInitialStudyTip TEXT NOT NULL
   )
   ''');
    await database.execute('''CREATE TABLE $studyTipsTableName(
   $studyTipsColumnId INTEGER,
   $studyTipsColumn TEXT NOT NULL,
   $isFav TEXT NOT NULL,
   $categoryId INTEGER,
   "FOREIGN KEY ($categoryId) REFERENCES $categoryTableName ($categoryColumnId) ON DELETE NO ACTION ON UPDATE NO ACTION") ''');
  }

  insertIntoCategory({required Map<String, dynamic> categoryTableRow}) async {
    Database db = await instance.getDatabase;
    await db.insert(categoryTableName, categoryTableRow);
  }

  insertIntoStudyTips(
      {required Map<String, dynamic> categoryDetailTableRow}) async {
    Database db = await instance.getDatabase;
    await db.insert(studyTipsTableName, categoryDetailTableRow);
  }

  Future queryCategoryTable(String tableName) async {
    return await database.query(tableName);
  }

  Future queryStudyTipsTable(String tableName) async {
    return await database.query(tableName);
  }

  Future queryCategory({required int catId}) async {
    return await database
        .rawQuery('SELECT * FROM $studyTipsTableName WHERE $categoryId=$catId');
  }

  Future update(
      {required int studyTipsId,
      required String isFav,
      required int catId}) async {
    return await database.update(studyTipsTableName, {"isFav": isFav},
        where: "$studyTipsColumnId = ? AND $categoryId=?",
        whereArgs: [studyTipsId, catId]);
  }

  Future singleStudyTips({required int studyTipsId, required int catId}) async {
    return await database.rawQuery(
        'SELECT * FROM $studyTipsTableName WHERE $studyTipsColumnId=$studyTipsId AND $categoryId=$catId');
  }

  Future favQuery() async {
    return await database
        .query(studyTipsTableName, where: "isFav LIKE ?", whereArgs: ['true']);
  }

  Future favoriteCopy({required int studyTipsId, required int catId}) async {
    return await database.query(studyTipsTableName,
        where: "isFav LIKE ? AND $studyTipsColumnId=? AND $categoryId=?",
        whereArgs: ['true', studyTipsId, catId]);
  }
}
