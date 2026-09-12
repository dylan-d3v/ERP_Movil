import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/app.dart';
import 'package:panaderia_erp/data/database/app_database.dart';

import 'helpers/test_locale.dart';

void main() {
  testWidgets('app starts with dashboard, products, sales and expenses tabs', (WidgetTester tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    addTearDown(database.close);
    await initializeSpanishLocaleForTests();

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pump();

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Ingresos del dia'), findsOneWidget);
    expect(find.text('\$0.00'), findsWidgets);
    expect(find.text('No hay productos con stock bajo.'), findsOneWidget);
    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Ventas'), findsOneWidget);
    expect(find.text('Egresos'), findsOneWidget);
  });
}
