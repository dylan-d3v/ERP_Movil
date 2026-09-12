import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/data/database/app_database.dart';
import 'package:panaderia_erp/data/repositories/product_repository.dart';
import 'package:panaderia_erp/data/repositories/sales_repository.dart';
import 'package:panaderia_erp/data/repositories/stock_repository.dart';

void main() {
  late AppDatabase database;
  late ProductRepository productRepository;
  late SalesRepository salesRepository;
  late StockRepository stockRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    productRepository = ProductRepository(database);
    salesRepository = SalesRepository(database);
    stockRepository = StockRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('creating and voiding a sale updates stock through movements', () async {
    final productId = await productRepository.createProduct(
      name: 'Pan de yuca',
      salePrice: 0.75,
    );

    await stockRepository.registerMovement(
      productId: productId,
      type: StockMovementType.entry,
      quantity: 20,
      reason: StockMovementReason.purchase,
    );

    final saleId = await salesRepository.createSale(
      items: [
        SaleItemInput(
          productId: productId,
          quantity: 4,
          unitPrice: 0.75,
        ),
      ],
    );

    expect(await stockRepository.getCurrentStockForProduct(productId), 16.0);

    final sale = await salesRepository.getSaleWithItems(saleId);
    expect(sale, isNotNull);
    expect(sale!.items, hasLength(1));
    expect(sale.sale.isVoided, isFalse);

    final voided = await salesRepository.voidSale(saleId);
    expect(voided, isTrue);
    expect(await stockRepository.getCurrentStockForProduct(productId), 20.0);
  });
}
