import 'package:bill_repository/bill_repository.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_bills/bill_overview/bill_overview.dart';
import 'package:qr_bills/form/form.dart';
import 'package:qr_bills/qr_scanner/view/scanner_screen.dart';

class BillsOverviewPage extends StatelessWidget {
  const BillsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BillOverviewBloc(billRepository: context.read<BillRepository>())
            ..add(const BillOverviewSubscriptionRequested())
            ..add(const BillOverviewSettingsRequested()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<BillOverviewBloc, BillOverviewState>(
            listenWhen: (previous, current) =>
                previous != current &&
                current.status == BillOverviewStatus.sendMessage,
            listener: (context, state) {
              final billResult = state.billResult;
              _showBillResultDialog(
                context,
                billResult.message,
                billResult.billResult,
              );
            },
          ),
          BlocListener<BillOverviewBloc, BillOverviewState>(
            listenWhen: (previous, current) =>
                previous != current &&
                current.status == BillOverviewStatus.error,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  state.billResult.message,
                  style: const TextStyle(fontSize: 16.0),
                ),
                duration: const Duration(seconds: 2),
              ));
            },
          ),
        ],
        child: const BillsOverviewScreen(),
      ),
    );
  }

  Future<void> _showBillResultDialog(
      BuildContext context, String message, List<dynamic> bill) {
    if (bill.isEmpty) return Future(() => null);
    return showDialog(
        context: context,
        builder: (BuildContext _) => AlertDialog(
              title: Text(message),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Name: ${bill[0]['name']}'),
                  // const SizedBox(height: 8),
                  Text('Date: ${bill[0]['date']}'),
                  Text('Price: ${bill[0]['price']}'),
                  Text('Items: ${bill[0]['items']}'),
                  Text('Duplicates: ${bill[0]['duplicates']}'),
                  RichText(
                      text: TextSpan(
                        text: 'URL',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context
                                .read<BillOverviewBloc>()
                                .add(BillOverviewLaunchUrl(bill[0]['link']));
                          },
                      ),
                      maxLines: 2),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }
}

class BillsOverviewScreen extends StatelessWidget {
  const BillsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<BillOverviewBloc, BillOverviewState>(
                builder: (context, state) {
                  switch (state.status) {
                    case BillOverviewStatus.initial:
                      return const Center(
                        child: Text('Initializing bills...'),
                      );
                    case BillOverviewStatus.loading:
                      return const CircularProgressIndicator();
                    case BillOverviewStatus.loaded || BillOverviewStatus.error:
                      final bills = state.bills;
                      if (bills.isEmpty) {
                        if (state.status == BillOverviewStatus.error &&
                            state.message.isEmpty) {
                          return const Center(
                            child: Text('Failed in bills set up.'),
                          );
                        }
                        return const Center(
                          child: Text('No bills'),
                        );
                      }

                      final height = MediaQuery.of(context).size.height;
                      return CustomScrollView(
                        reverse: true,
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final bill = bills[index];
                                return BillCard(bill: bill, index: index);
                              },
                              childCount: bills.length,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: height / 2,
                            ),
                          ),
                        ],
                      );
                    default:
                      return const Center(
                        child: Text('Default state.'),
                      );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.menu),
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'chooseServer',
                          child: const Text('Server URL'),
                          onTap: () async {
                            await _dialogEditServerUrl(context);
                          },
                        ),
                      ];
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            Navigator.of(context).push(ScannerPage.route()),
                        color: Colors.blue,
                        icon: const Icon(Icons.qr_code_scanner),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.of(context).push(FormPage.route()),
                        color: Colors.orange,
                        icon: const Icon(Icons.article_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      //floatingActionButton: Column(
      //  mainAxisSize: MainAxisSize.min,
      //  children: [
      //    Padding(
      //      padding: const EdgeInsets.all(8.0),
      //      child: FloatingActionButton(
      //        heroTag: 'qr',
      //        onPressed: () {
      //          Navigator.of(context).push(ScannerPage.route());
      //        },
      //        child: const Icon(Icons.qr_code_scanner),
      //      ),
      //    ),
      //    Padding(
      //      padding: const EdgeInsets.all(8.0),
      //      child: FloatingActionButton(
      //        heroTag: 'form',
      //        onPressed: () {
      //          Navigator.of(context).push(FormPage.route());
      //        },
      //        child: const Icon(Icons.article_outlined),
      //      ),
      //    ),
      //  ],
      //),
      //floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _dialogEditServerUrl(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext _) {
        final urlInitial = context.read<BillOverviewBloc>().state.serverUrl;
        return AlertDialog(
          title: const Text('Edit server url'),
          content: TextFormField(
            initialValue: urlInitial,
            onChanged: (urlNew) => context
                .read<BillOverviewBloc>()
                .add(BillOverviewServerUrlChanged(urlNew)),
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
                Navigator.of(context).pop();
                context
                    .read<BillOverviewBloc>()
                    .add(const BillOverviewServerUrlSubmit());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
