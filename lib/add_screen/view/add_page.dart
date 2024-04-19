import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_bills/add_screen/add_screen.dart';
import 'package:qr_bills/form/form.dart';
import 'package:qr_bills/qr_scanner/view/scanner_screen.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  static Route route() {
    return MaterialPageRoute(builder: (context) => const AddPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddPageCubit(),
      child: const AddScreen(),
    );
  }
}

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTab =
        context.select<AddPageCubit, AddTab>((cubit) => cubit.state.tab);
    return Scaffold(
      body: IndexedStack(
        index: selectedTab.index,
        children: const [
          ScannerPage(),
          FormPage(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _HomeTabButton(
                groupValue: selectedTab,
                value: AddTab.form,
                icon: const Icon(Icons.description_outlined)),
            _HomeTabButton(
                groupValue: selectedTab,
                value: AddTab.qr,
                icon: const Icon(Icons.qr_code)),
          ],
        ),
      ),
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    required this.groupValue,
    required this.value,
    required this.icon,
  });

  final AddTab groupValue;
  final AddTab value;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.read<AddPageCubit>().setTab(value),
      iconSize: 32,
      color:
          groupValue != value ? null : Theme.of(context).colorScheme.secondary,
      icon: icon,
    );
  }
}
