import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/app.dart';
import 'package:panaderia_erp/data/database/app_database.dart';
import 'package:panaderia_erp/data/repositories/expense_repository.dart';
import 'package:panaderia_erp/ui/screens/expenses/expense_controller.dart';
import 'package:provider/provider.dart';

import '../helpers/test_locale.dart';

void main() {
  testWidgets('allows creating and editing an expense', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    addTearDown(database.close);
    await initializeSpanishLocaleForTests();

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Egresos'));
    await tester.pumpAndSettle();

    expect(find.text('No hay egresos registrados'), findsOneWidget);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Nuevo egreso'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Categoria'),
      'Transporte',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Monto'),
      '12.50',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Notas'),
      'Entrega de insumos',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Transporte'), findsOneWidget);
    expect(find.text('Monto: \$12.50'), findsOneWidget);
    expect(find.text('Egreso registrado correctamente'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Categoria'),
      'Transporte local',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Actualizar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Transporte local'), findsOneWidget);
    expect(find.text('Egreso actualizado correctamente'), findsOneWidget);
  });

  testWidgets('shows delete action and keeps expense when canceling deletion', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final expenseRepository = ExpenseRepository(database);

    addTearDown(database.close);
    await initializeSpanishLocaleForTests();

    await expenseRepository.createExpense(
      category: 'Luz',
      amount: 22.10,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Egresos'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('Eliminar egreso'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Luz'), findsOneWidget);
  });

  testWidgets('deletes expense after confirming and shows empty state', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final expenseRepository = ExpenseRepository(database);

    addTearDown(database.close);
    await initializeSpanishLocaleForTests();

    await expenseRepository.createExpense(
      category: 'Gas',
      amount: 15,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Egresos'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Gas'), findsNothing);
    expect(find.text('No hay egresos registrados'), findsOneWidget);
  });

  testWidgets('refreshes list after deleting with active filter', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final expenseRepository = ExpenseRepository(database);

    addTearDown(database.close);
    await initializeSpanishLocaleForTests();

    final now = DateTime.now();
    await expenseRepository.createExpense(
      category: 'Reciente',
      amount: 10,
      createdAt: now.subtract(const Duration(days: 1)),
    );
    await expenseRepository.createExpense(
      category: 'Antiguo',
      amount: 20,
      createdAt: now.subtract(const Duration(days: 40)),
    );

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Egresos'));
    await tester.pumpAndSettle();

    final expensesContext = tester.element(find.byType(Scaffold).first);
    final controller =
        Provider.of<ExpenseController>(expensesContext, listen: false);

    await controller.applyFilter(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
    await tester.pumpAndSettle();

    expect(find.text('Reciente'), findsOneWidget);
    expect(find.text('Antiguo'), findsNothing);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Reciente'), findsNothing);
    expect(find.text('Antiguo'), findsNothing);
    expect(find.text('No hay egresos registrados'), findsOneWidget);
  });
}
