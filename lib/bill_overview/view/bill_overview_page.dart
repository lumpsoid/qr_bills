import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_bills/bill_overview/bloc/bill_overview_bloc.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => BillOverviewBloc(), child: const BillsScreen());
  }
}

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'chooseServer',
                  child: const Text('Server URL'),
                  onTap: () async {
                    var newUrl = await SettingsManager.getServerUrl();
                    await _dialogEditServerUrl(context, newUrl);
                  },
                ),
                PopupMenuItem<String>(
                  value: 'option2',
                  child: const Text('Option 2'),
                  onTap: () {},
                ),
                const PopupMenuItem<String>(
                  value: 'option3',
                  child: Text('Option 3'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Selector<BillsManager, int?>(
                selector: (context, manager) => manager.itemCount,
                builder: (context, itemCount, child) => ListView.builder(
                  // padding: const EdgeInsets.only(bottom: 64.0),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    BillsManager manager = Provider.of<BillsManager>(context);
                    final bill = manager.getByIndex(index);

                    // Use a different approach to create NoteCard based on note state
                    if (bill.isLoading) {
                      return const BillCardLoading();
                    } else {
                      return BillCard(bill: bill, index: index);
                    }
                  },
                ),
              ),
            ),
            Dismissible(
                // drag to the right (edit)
                background: Container(
                  color: Colors.blue[50],
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 30.0),
                  child: const Icon(Icons.text_snippet_outlined),
                ),
                // drag to the left (delete)
                secondaryBackground: Container(
                  color: Colors.green[50],
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 30.0),
                  child: const Icon(Icons.qr_code),
                ),
                confirmDismiss: (DismissDirection direction) async {
                  // start form
                  if (direction == DismissDirection.startToEnd) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FormFillScreen()),
                    );
                    return false;
                  }
                  // start qr scan
                  if (direction == DismissDirection.endToStart) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScannerScreen()),
                    );
                    return false;
                  }
                  return false;
                },
                key: const Key('qwertyuiop'),
                child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 16.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    child: const Text("Add new",
                        style: TextStyle(fontSize: 16.0))))
          ],
        ),
      ),
    );
  }

  Future<void> _dialogEditServerUrl(BuildContext context, String newUrl) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit server url'),
          content: TextFormField(
            initialValue: newUrl,
            onChanged: (value) {
              newUrl = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newUrl.isNotEmpty) {
                  // Update the item in the list
                  SettingsManager.setServerUrl(newUrl);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
