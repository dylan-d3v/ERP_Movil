import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  RealColumn get salePrice =>
      real().customConstraint('CHECK (sale_price > 0)')();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isVoided => boolean().withDefault(const Constant(false))();
}

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get saleId => integer().references(Sales, #id)();

  IntColumn get productId => integer().references(Products, #id)();

  RealColumn get quantity => real().customConstraint('CHECK (quantity > 0)')();

  RealColumn get unitPrice =>
      real().customConstraint('CHECK (unit_price > 0)')();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get category => text().withLength(min: 1, max: 80)();

  RealColumn get amount => real().customConstraint('CHECK (amount > 0)')();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get productId => integer().references(Products, #id)();

  TextColumn get type =>
      text().customConstraint("CHECK (type IN ('entry', 'exit'))")();

  RealColumn get quantity => real().customConstraint('CHECK (quantity > 0)')();

  TextColumn get reason => text().withLength(min: 1, max: 80)();

  IntColumn get referenceId => integer().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class StockMovementType {
  static const entry = 'entry';
  static const exit = 'exit';
}

class StockMovementReason {
  static const sale = 'sale';
  static const saleVoid = 'sale_void';
  static const adjustment = 'adjustment';
  static const purchase = 'purchase';
}

@DriftDatabase(
  tables: [
    Products,
    Sales,
    SaleItems,
    Expenses,
    StockMovements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'panaderia_erp.db'));
    return NativeDatabase.createInBackground(file);
  });
}
