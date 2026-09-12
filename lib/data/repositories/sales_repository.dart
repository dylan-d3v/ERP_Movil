import 'package:drift/drift.dart' as drift;

import '../database/app_database.dart';
import 'stock_repository.dart';

class SaleItemInput {
  final int productId;
  final double quantity;
  final double unitPrice;

  const SaleItemInput({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });
}

class SaleWithItems {
  final Sale sale;
  final List<SaleItem> items;

  const SaleWithItems({
    required this.sale,
    required this.items,
  });
}

class SalesRepository {
  final AppDatabase _database;
  final StockRepository _stockRepository;

  SalesRepository(this._database) : _stockRepository = StockRepository(_database);

  Future<int> createSale({
    required List<SaleItemInput> items,
    DateTime? createdAt,
  }) {
    return _database.transaction(() async {
      final saleId = await _database.into(_database.sales).insert(
            SalesCompanion.insert(
              createdAt: drift.Value(createdAt ?? DateTime.now()),
            ),
          );

      for (final item in items) {
        await _database.into(_database.saleItems).insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: item.productId,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
              ),
            );

        await _stockRepository.registerMovement(
          productId: item.productId,
          type: StockMovementType.exit,
          quantity: item.quantity,
          reason: StockMovementReason.sale,
          referenceId: saleId,
          createdAt: createdAt,
        );
      }

      return saleId;
    });
  }

  Future<List<Sale>> getRecentSales() {
    return (_database.select(_database.sales)
          ..orderBy([(table) => drift.OrderingTerm.desc(table.createdAt)]))
        .get();
  }

  Future<double> getSalesTotalByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final sales = await (_database.select(_database.sales)
          ..where(
            (table) =>
                table.createdAt.isBetweenValues(start, end) &
                table.isVoided.equals(false),
          ))
        .get();

    if (sales.isEmpty) {
      return 0;
    }

    final saleIds = sales.map((sale) => sale.id).toList();
    final items = await (_database.select(_database.saleItems)
          ..where((table) => table.saleId.isIn(saleIds)))
        .get();

    return items.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * item.unitPrice),
    );
  }

  Future<SaleWithItems?> getSaleWithItems(int saleId) async {
    final sale = await (_database.select(_database.sales)
          ..where((table) => table.id.equals(saleId)))
        .getSingleOrNull();

    if (sale == null) {
      return null;
    }

    final items = await (_database.select(_database.saleItems)
          ..where((table) => table.saleId.equals(saleId)))
        .get();

    return SaleWithItems(sale: sale, items: items);
  }

  Future<List<SaleWithItems>> getSalesWithItemsByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final sales = await (_database.select(_database.sales)
          ..where(
            (table) =>
                table.createdAt.isBetweenValues(start, end) &
                table.isVoided.equals(false),
          )
          ..orderBy([(table) => drift.OrderingTerm.desc(table.createdAt)]))
        .get();

    if (sales.isEmpty) {
      return [];
    }

    final saleIds = sales.map((s) => s.id).toList();
    final items = await (_database.select(_database.saleItems)
          ..where((table) => table.saleId.isIn(saleIds)))
        .get();

    final itemsBySaleId = <int, List<SaleItem>>{};
    for (final item in items) {
      itemsBySaleId.putIfAbsent(item.saleId, () => []).add(item);
    }

    return sales.map((sale) {
      return SaleWithItems(
        sale: sale,
        items: itemsBySaleId[sale.id] ?? [],
      );
    }).toList();
  }

  Future<bool> voidSale(int saleId) {
    return _database.transaction(() async {
      final saleWithItems = await getSaleWithItems(saleId);
      if (saleWithItems == null || saleWithItems.sale.isVoided) {
        return false;
      }

      final updated = await (_database.update(_database.sales)
            ..where((table) => table.id.equals(saleId)))
          .write(
            const SalesCompanion(
              isVoided: drift.Value(true),
            ),
          );

      for (final item in saleWithItems.items) {
        await _stockRepository.registerMovement(
          productId: item.productId,
          type: StockMovementType.entry,
          quantity: item.quantity,
          reason: StockMovementReason.saleVoid,
          referenceId: saleId,
        );
      }

      return updated > 0;
    });
  }
}
