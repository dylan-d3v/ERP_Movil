import 'package:drift/drift.dart';

import '../database/app_database.dart';

class ProductRepository {
  final AppDatabase _database;

  ProductRepository(this._database);

  Future<int> createProduct({
    required String name,
    required double salePrice,
  }) {
    return _database.into(_database.products).insert(
          ProductsCompanion.insert(
            name: name,
            salePrice: salePrice,
          ),
        );
  }

  Future<List<Product>> getActiveProducts() {
    return (_database.select(_database.products)
          ..where((table) => table.isActive.equals(true))
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
  }

  Future<Product?> getProductById(int id) {
    return (_database.select(_database.products)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateProduct({
    required int id,
    required String name,
    required double salePrice,
    required bool isActive,
  }) async {
    final rowsAffected = await (_database.update(_database.products)
          ..where((table) => table.id.equals(id)))
        .write(
          ProductsCompanion(
            name: Value(name),
            salePrice: Value(salePrice),
            isActive: Value(isActive),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return rowsAffected > 0;
  }

  Future<bool> deactivateProduct(int id) async {
    final rowsAffected = await (_database.update(_database.products)
          ..where((table) => table.id.equals(id)))
        .write(
          ProductsCompanion(
            isActive: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return rowsAffected > 0;
  }
}
