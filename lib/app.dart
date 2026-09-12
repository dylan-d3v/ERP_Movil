import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/database/app_database.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/sales_repository.dart';
import 'data/repositories/stock_repository.dart';
import 'ui/screens/dashboard/dashboard_controller.dart';
import 'ui/screens/expenses/expense_controller.dart';
import 'ui/screens/home/home_controller.dart';
import 'ui/screens/main/main_screen.dart';
import 'ui/screens/sales/sales_controller.dart';

class App extends StatelessWidget {
  final AppDatabase database;

  const App({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<ProductRepository>(
          create: (context) => ProductRepository(context.read<AppDatabase>()),
        ),
        Provider<StockRepository>(
          create: (context) => StockRepository(context.read<AppDatabase>()),
        ),
        Provider<SalesRepository>(
          create: (context) => SalesRepository(context.read<AppDatabase>()),
        ),
        Provider<ExpenseRepository>(
          create: (context) => ExpenseRepository(context.read<AppDatabase>()),
        ),
        ChangeNotifierProvider<HomeController>(
          create: (context) => HomeController(
            productRepository: context.read<ProductRepository>(),
            stockRepository: context.read<StockRepository>(),
          )..loadProducts(),
        ),
        ChangeNotifierProvider<SalesController>(
          create: (context) => SalesController(
            productRepository: context.read<ProductRepository>(),
            stockRepository: context.read<StockRepository>(),
            salesRepository: context.read<SalesRepository>(),
            homeController: context.read<HomeController>(),
          )..loadProducts(),
        ),
        ChangeNotifierProvider<ExpenseController>(
          create: (context) => ExpenseController(
            expenseRepository: context.read<ExpenseRepository>(),
          )..loadExpenses(),
        ),
        ChangeNotifierProvider<DashboardController>(
          create: (context) => DashboardController(
            salesRepository: context.read<SalesRepository>(),
            expenseRepository: context.read<ExpenseRepository>(),
            productRepository: context.read<ProductRepository>(),
            stockRepository: context.read<StockRepository>(),
          )..loadDashboard(),
        ),
      ],
      child: MaterialApp(
        title: 'Panaderia ERP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
