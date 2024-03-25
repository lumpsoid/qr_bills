import 'package:bill_repository/bill_repository.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_bills/bill_overview/bill_overview.dart';
import 'package:qr_bills/form/form.dart';

class BillsOverviewPage extends StatelessWidget {
  const BillsOverviewPage({super.key});

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) =>
            BillOverviewBloc(billRepository: context.read<BillRepository>()),
        child: const BillsOverviewPage(),
      ),
    );
  }

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
                  context, billResult.message, billResult.billResult);
            },
          ),
          //BlocListener<SubjectBloc, SubjectState>(
          //  listener: (context, state) {
          //    // TODO: implement listener
          //  },
          //),
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
              title: const Text('Bill Information'),
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
                            // _launchURL(bill[0]['link']);
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
                    await _dialogEditServerUrl(context);
                  },
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
              child: BlocBuilder<BillOverviewBloc, BillOverviewState>(
                builder: (context, state) {
                  switch (state.status) {
                    case BillOverviewStatus.initial:
                      return const BillCardLoading();
                    case BillOverviewStatus.loading:
                      return const BillCardLoading();
                    case BillOverviewStatus.error:
                      return const BillCardLoading();
                    case BillOverviewStatus.loaded:
                      final bills = state.bills;
                      return ListView.builder(
                        itemCount: bills.length,
                        itemBuilder: (context, index) {
                          final bill = bills[index];
                          if (bill.isLoading) {
                            return const BillCardLoading();
                          } else {
                            return BillCard(bill: bill, index: index);
                          }
                        },
                      );
                    default:
                      return const BillCardLoading();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(FormPage.route());
        },
        child: const Icon(Icons.add),
      ),
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
                //context
                //    .read<BillOverviewBloc>()
                //    .add(const BillOverviewServerUrlCanceled());
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
