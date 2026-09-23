import 'package:flutter/foundation.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/stock_repository.dart';

class ProductStockViewData {
  final Product product;
  final double stock;

  const ProductStockViewData({
    required this.product,
    required this.stock,
  });
}

class HomeController extends ChangeNotifier {
  final ProductRepository _productRepository;
  final StockRepository _stockRepository;

  HomeController({
    required ProductRepository productRepository,
    required StockRepository stockRepository,
  })  : _productRepository = productRepository,
        _stockRepository = stockRepository;

  bool _isLoading = false;
  List<ProductStockViewData> _products = const [];
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  List<ProductStockViewData> get products => _products;
  String get searchQuery => _searchQuery;

  List<ProductStockViewData> get filteredProducts {
    if (_searchQuery.trim().isEmpty) {
      return _products;
    }
    final query = _searchQuery.trim().toLowerCase();
    return _products
        .where((item) => item.product.name.toLowerCase().contains(query))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    final activeProducts = await _productRepository.getActiveProducts();
    final stockEntries = <ProductStockViewData>[];

    for (final product in activeProducts) {
      final stock = await _stockRepository.getCurrentStockForProduct(product.id);
      stockEntries.add(
        ProductStockViewData(
          product: product,
          stock: stock,
        ),
      );
    }

    _products = stockEntries;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createProduct({
    required String name,
    required double salePrice,
  }) async {
    await _productRepository.createProduct(
      name: name,
      salePrice: salePrice,
    );
    await loadProducts();
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required double salePrice,
    required bool isActive,
  }) async {
    await _productRepository.updateProduct(
      id: id,
      name: name,
      salePrice: salePrice,
      isActive: isActive,
    );
    await loadProducts();
  }

  Future<void> deactivateProduct(int id) async {
    await _productRepository.deactivateProduct(id);
    await loadProducts();
  }

  Future<void> adjustStock({
    required int productId,
    required String type,
    required double quantity,
  }) async {
    await _stockRepository.registerMovement(
      productId: productId,
      type: type,
      quantity: quantity,
      reason: StockMovementReason.adjustment,
    );
    await loadProducts();
  }
}
