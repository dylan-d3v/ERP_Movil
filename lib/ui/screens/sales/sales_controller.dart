import 'package:flutter/foundation.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../data/repositories/stock_repository.dart';
import '../home/home_controller.dart';

class SalesProductViewData {
  final Product product;
  final double stock;

  const SalesProductViewData({
    required this.product,
    required this.stock,
  });
}

class SaleLineDraft {
  int? productId;
  double quantity;

  SaleLineDraft({
    this.productId,
    this.quantity = 1,
  });
}

class SalesController extends ChangeNotifier {
  final ProductRepository _productRepository;
  final StockRepository _stockRepository;
  final SalesRepository _salesRepository;
  final HomeController _homeController;

  SalesController({
    required ProductRepository productRepository,
    required StockRepository stockRepository,
    required SalesRepository salesRepository,
    required HomeController homeController,
  })  : _productRepository = productRepository,
        _stockRepository = stockRepository,
        _salesRepository = salesRepository,
        _homeController = homeController;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _message;
  List<SalesProductViewData> _products = const [];
  final List<SaleLineDraft> _lines = [SaleLineDraft()];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get message => _message;
  List<SalesProductViewData> get products => _products;
  List<SaleLineDraft> get lines => List.unmodifiable(_lines);

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    final activeProducts = await _productRepository.getActiveProducts();
    final productEntries = <SalesProductViewData>[];

    for (final product in activeProducts) {
      final stock = await _stockRepository.getCurrentStockForProduct(product.id);
      productEntries.add(
        SalesProductViewData(
          product: product,
          stock: stock,
        ),
      );
    }

    _products = productEntries;
    _isLoading = false;
    notifyListeners();
  }

  void clearMessage() {
    _message = null;
    notifyListeners();
  }

  void addLine() {
    _lines.add(SaleLineDraft());
    notifyListeners();
  }

  void removeLine(int index) {
    if (_lines.length == 1) {
      _lines[0] = SaleLineDraft();
    } else {
      _lines.removeAt(index);
    }
    notifyListeners();
  }

  void updateLineProduct(int index, int? productId) {
    _lines[index].productId = productId;
    _message = null;
    notifyListeners();
  }

  void updateLineQuantity(int index, double quantity) {
    _lines[index].quantity = quantity;
    _message = null;
    notifyListeners();
  }

  SalesProductViewData? getProductData(int? productId) {
    if (productId == null) {
      return null;
    }

    for (final item in _products) {
      if (item.product.id == productId) {
        return item;
      }
    }

    return null;
  }

  double lineSubtotal(SaleLineDraft line) {
    final productData = getProductData(line.productId);
    if (productData == null || line.quantity <= 0) {
      return 0;
    }

    return productData.product.salePrice * line.quantity;
  }

  double get total {
    return _lines.fold<double>(0, (sum, line) => sum + lineSubtotal(line));
  }

  String? validate() {
    if (_lines.isEmpty) {
      return 'Agrega al menos una linea de venta';
    }

    final selectedIds = <int>{};

    for (final line in _lines) {
      if (line.productId == null) {
        return 'Selecciona un producto en cada linea';
      }

      if (!selectedIds.add(line.productId!)) {
        return 'No repitas productos en la misma venta';
      }

      if (line.quantity <= 0) {
        return 'Cada cantidad debe ser mayor a cero';
      }

      final productData = getProductData(line.productId);
      if (productData == null) {
        return 'Uno de los productos ya no esta disponible';
      }

      if (productData.stock < line.quantity) {
        return 'No hay stock suficiente para ${productData.product.name}';
      }
    }

    return null;
  }

  Future<bool> submitSale() async {
    final validationError = validate();
    if (validationError != null) {
      _message = validationError;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _message = null;
    notifyListeners();

    final items = _lines
        .where((line) => line.productId != null)
        .map(
          (line) => SaleItemInput(
            productId: line.productId!,
            quantity: line.quantity,
            unitPrice: getProductData(line.productId)!.product.salePrice,
          ),
        )
        .toList();

    await _salesRepository.createSale(items: items);

    _lines
      ..clear()
      ..add(SaleLineDraft());

    _message = 'Venta registrada correctamente';
    _isSaving = false;

    await loadProducts();
    await _homeController.loadProducts();
    notifyListeners();
    return true;
  }
}
