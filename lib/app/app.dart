import 'package:bill_repository/bill_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_bills/bill_overview/bill_overview.dart';

class App extends StatelessWidget {
  const App({required this.billsRepository, super.key});

  final BillRepository billsRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: billsRepository,
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // theme: FlutterTodosTheme.light,
      // darkTheme: FlutterTodosTheme.dark,
      home: BillsPage(),
    );
  }
}
