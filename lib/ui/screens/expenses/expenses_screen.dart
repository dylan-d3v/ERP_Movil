import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/database/app_database.dart';
import 'expense_controller.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Egresos'),
            actions: [
              IconButton(
                onPressed: () => _showFilterDialog(context),
                icon: const Icon(Icons.filter_alt_outlined),
                tooltip: 'Filtrar',
              ),
              if (controller.activeFilter != null)
                IconButton(
                  onPressed: controller.clearFilter,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  tooltip: 'Limpiar filtro',
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showExpenseDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo egreso'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: controller.loadExpenses,
                  child: controller.expenses.isEmpty
                      ? const _ExpensesEmptyState()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (controller.message != null) ...[
                              _ExpenseMessageBanner(message: controller.message!),
                              const SizedBox(height: 16),
                            ],
                            ...controller.expenses.map(
                              (expense) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ExpenseCard(
                                  expense: expense,
                                  onEdit: () =>
                                      _showExpenseDialog(context, expense: expense),
                                  onDelete: () =>
                                      _confirmDeleteExpense(context, expense),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
        );
      },
    );
  }
}

class _ExpensesEmptyState extends StatelessWidget {
  const _ExpensesEmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 72, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'No hay egresos registrados',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Registra tu primer egreso para empezar a controlar tus gastos.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpenseMessageBanner extends StatelessWidget {
  final String message;

  const _ExpenseMessageBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(color: Colors.green.shade900),
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = expense.createdAt;
    final dateText =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Card(
      child: ListTile(
        title: Text(expense.category),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monto: \$${expense.amount.toStringAsFixed(2)}'),
            Text('Fecha: $dateText'),
            if (expense.notes != null && expense.notes!.trim().isNotEmpty)
              Text('Notas: ${expense.notes}'),
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar egreso',
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar egreso',
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDeleteExpense(BuildContext context, Expense expense) async {
  final controller = context.read<ExpenseController>();
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Eliminar egreso'),
        content: const Text(
          'Esta accion es irreversible. El egreso se eliminara definitivamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    await controller.deleteExpense(id: expense.id);
  }
}

Future<void> _showExpenseDialog(
  BuildContext context, {
  Expense? expense,
}) async {
  final formKey = GlobalKey<FormState>();
  final controller = context.read<ExpenseController>();
  final categoryController = TextEditingController(text: expense?.category ?? '');
  final amountController = TextEditingController(
    text: expense != null ? expense.amount.toStringAsFixed(2) : '',
  );
  final notesController = TextEditingController(text: expense?.notes ?? '');
  var selectedDate = expense?.createdAt ?? DateTime.now();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final dateText =
              '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';

          return AlertDialog(
            title: Text(expense == null ? 'Nuevo egreso' : 'Editar egreso'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa una categoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Monto'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Ingresa un monto mayor a cero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notas'),
                      minLines: 2,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fecha'),
                      subtitle: Text(dateText),
                      trailing: IconButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                selectedDate.hour,
                                selectedDate.minute,
                              );
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  final category = categoryController.text.trim();
                  final amount = double.parse(amountController.text);
                  final notes = notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim();

                  if (expense == null) {
                    await controller.createExpense(
                      category: category,
                      amount: amount,
                      notes: notes,
                      date: selectedDate,
                    );
                  } else {
                    await controller.updateExpense(
                      id: expense.id,
                      category: category,
                      amount: amount,
                      notes: notes,
                      date: selectedDate,
                    );
                  }

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(expense == null ? 'Guardar' : 'Actualizar'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showFilterDialog(BuildContext context) async {
  final controller = context.read<ExpenseController>();
  var start = controller.activeFilter?.start ??
      DateTime.now().subtract(const Duration(days: 30));
  var end = controller.activeFilter?.end ?? DateTime.now();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          String formatDate(DateTime date) =>
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

          return AlertDialog(
            title: const Text('Filtrar egresos'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha inicio'),
                  subtitle: Text(formatDate(start)),
                  trailing: IconButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: dialogContext,
                        initialDate: start,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          start = pickedDate;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha fin'),
                  subtitle: Text(formatDate(end)),
                  trailing: IconButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: dialogContext,
                        initialDate: end,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          end = pickedDate;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  await controller.applyFilter(start: start, end: end);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      );
    },
  );
}
