import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_bills/src/bills_manager.dart';
import 'package:bill/bill.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              formats: [BarcodeFormat.qrCode],
            ),
            onDetect: (capture) {
              Navigator.pop(context);
              BillsManager manager = context.read<BillsManager>();
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                debugPrint('Barcode found! ${barcode.rawValue}');
                if (barcode.displayValue == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Value of the qr is NULL",
                        style: TextStyle(fontSize: 16.0)),
                    duration: Duration(seconds: 2),
                  ));
                } else {
                  manager.addBill(
                      BillBodyQr(barcode.displayValue!), BillType.qr);
                }
              }
            },
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back'),
            ),
          ),
        ],
      ),
    );
  }
}
