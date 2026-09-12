import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/dashboard_screen.dart';
import 'sales_controller.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesController>(
      builder: (context, controller, child) {
        final hasProducts = controller.products.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ventas'),
          ),
          floatingActionButton: hasProducts
              ? FloatingActionButton.extended(
                  onPressed: controller.addLine,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar linea'),
                )
              : null,
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : !hasProducts
                  ? const _SalesEmptyState()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (controller.message != null) ...[
                          _MessageBanner(message: controller.message!),
                          const SizedBox(height: 16),
                        ],
                        ...List.generate(
                          controller.lines.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SaleLineCard(index: index),
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total: \$${controller.total.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge,
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: controller.isSaving
                                        ? null
                                        : () async {
                                            await controller.submitSale();
                                          },
                                    icon: const Icon(Icons.save_outlined),
                                    label: Text(
                                      controller.isSaving
                                          ? 'Guardando...'
                                          : 'Confirmar venta',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}

class _SalesEmptyState extends StatelessWidget {
  const _SalesEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.point_of_sale_outlined, size: 72, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'No hay productos activos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Primero crea productos en la pestaña Productos para poder registrar ventas.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String message;

  const _MessageBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final isError = !message.toLowerCase().contains('correctamente');

    return Material(
      color: isError ? Colors.red.shade50 : Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(
            color: isError ? Colors.red.shade900 : Colors.green.shade900,
          ),
        ),
      ),
    );
  }
}

class _SaleLineCard extends StatelessWidget {
  final int index;

  const _SaleLineCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesController>(
      builder: (context, controller, child) {
        final line = controller.lines[index];
        final productData = controller.getProductData(line.productId);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Linea ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.removeLine(index),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Eliminar linea',
                    ),
                  ],
                ),
                DropdownButtonFormField<int>(
                  initialValue: line.productId,
                  decoration: const InputDecoration(
                    labelText: 'Producto',
                  ),
                  items: controller.products
                      .map(
                        (item) => DropdownMenuItem<int>(
                          value: item.product.id,
                          child: Text(item.product.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    controller.updateLineProduct(index, value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: line.quantity.toStringAsFixed(2),
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    controller.updateLineQuantity(
                      index,
                      double.tryParse(value) ?? 0,
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Precio unitario: \$${(productData?.product.salePrice ?? 0).toStringAsFixed(2)}',
                ),
                Text(
                  'Stock disponible: ${formatStock(productData?.stock ?? 0)}',
                ),
                Text(
                  'Subtotal: \$${controller.lineSubtotal(line).toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
