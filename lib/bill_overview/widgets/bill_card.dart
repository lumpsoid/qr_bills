import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_bills/bill_overview/bloc/bill_overview_bloc.dart';
import 'package:bill/bill.dart';

class BillCard extends StatelessWidget {
  final int index;
  final Bill bill;

  const BillCard({required this.bill, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    late final Widget billTypeIcon;
    switch (bill.type) {
      case BillType.qr:
        billTypeIcon = const Icon(
          Icons.qr_code,
          color: Colors.blue,
        );
      case BillType.form:
        billTypeIcon = const Icon(
          Icons.text_fields,
          color: Colors.grey,
        );
      case BillType.loading:
        billTypeIcon = const Icon(Icons.sync);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              offset: const Offset(25.0, 30.0),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    child: const Text('Info'),
                    onTap: () {
                      _showBillInfoDialog(context);
                    },
                  ),
                  PopupMenuItem<String>(
                    child: const Text('Delete'),
                    onTap: () {
                      context
                          .read<BillOverviewBloc>()
                          .add(BillOverviewDeleteBill(bill.id));
                    },
                  ),
                ];
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: billTypeIcon,
            ),
            Text(bill.name, style: const TextStyle(fontSize: 16.0)),
          ],
        ),
        IconButton(
          icon: BlocSelector<BillOverviewBloc, BillOverviewState, bool>(
            selector: (state) {
              if (state.status != BillOverviewStatus.loaded) {
                return false;
              }
              return state.billsBeingSent.contains(bill.id);
            },
            builder: (context, isSending) {
              return isSending
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.send);
            },
          ),
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          onPressed: () {
            context.read<BillOverviewBloc>().add(BillOverviewSendBill(bill));
          },
        ),
      ],
    );
  }

  Future<void> _showBillInfoDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext _) => AlertDialog(
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
                                ..onTap = () => context
                                    .read<BillOverviewBloc>()
                                    .add(BillOverviewLaunchUrl(
                                        bill.body.getUrl())),
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
}
