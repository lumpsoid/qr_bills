import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bill/bill.dart';

import '../../src/bills_manager.dart' show BillsManager;

class BillCard extends StatelessWidget {
  final int index;
  final Bill bill;

  const BillCard({required this.bill, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // TODO write functionality
      PopupMenuButton<String>(
        offset: const Offset(25.0, 30.0),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<String>(
              // value: '',
              child: const Text('Info'),
              onTap: () {
                _showBillInfoDialog(context);
              },
            ),
            const PopupMenuItem<String>(
              value: 'option2',
              child: Text('Select'),
            ),
            PopupMenuItem<String>(
              // value: 'option3',
              child: const Text('Delete'),
              onTap: () {
                context.read<BillsManager>().deleteBill(index);
              },
            ),
          ];
        },
      ),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(bill.dateCreated, style: const TextStyle(fontSize: 16.0)),
      )),
      IconButton(
        icon: Selector<BillsManager, bool>(
          selector: (context, manager) => manager.isOnSend(bill.id),
          builder: (context, isSending, child) {
            return isSending
                ? const CircularProgressIndicator()
                : const Icon(Icons.send);
          },
        ),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        onPressed: () {
          _tapOnSend(context, bill, index);
        },
      ),
      // TextButton(onPressed: onPressed, child: child),
    ]);
  }

  Future<void> _showBillInfoDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Bill Information'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Creation Date: ${bill.dateCreated}'),
                  const SizedBox(height: 8),
                  RichText(
                      text: TextSpan(
                          text: 'URL: ',
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: bill.body.getUrl(),
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchURL(bill.body.getUrl()),
                            ),
                          ]),
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

  Future<void> _showBillResultDialog(BuildContext context, List<dynamic> bill) {
    if (bill.isEmpty) return Future(() => null);
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
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
                            _launchURL(bill[0]['link']);
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

  Future<void> _launchURL(String url) async {
    final Uri urlParsed = Uri.parse(url);
    if (!await launchUrl(urlParsed)) {
      throw Exception('Could not launch $urlParsed');
    }
  }

  void _tapOnSend(BuildContext context, Bill bill, int index) async {
    String message;
    BillsManager manager = context.read<BillsManager>();
    manager.startSend(bill.id);
    Map<String, dynamic> result = await manager.sendQr(index, bill);
    switch (result['enum']) {
      case SendResult.success:
        message = 'Bill was added successfully.';
        _showBillResultDialog(context, result['bill']);
        break;
      case SendResult.socketException:
        message = 'Wrong server url. May be port.';
        break;
      case SendResult.parseError:
        message = 'Site parse failed.';
        _showBillResultDialog(context, result['bill']);
        break;
      case SendResult.duplicates:
        message = 'Duplicate was found in the Database.';
        _showBillResultDialog(context, result['bill']);
        break;
      case SendResult.error:
        message = 'SendResult.error was received. This should not happen.';
        break;
      case SendResult.typeMismatch:
        message = 'Server sent not a valid json.';
        break;
      default:
        message = 'It is more absurd then SendResult.error.';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontSize: 16.0)),
      duration: const Duration(seconds: 2),
    ));
    manager.stopSend(bill.id);
  }
}

class BillCardLoading extends StatelessWidget {
  const BillCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '...',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
