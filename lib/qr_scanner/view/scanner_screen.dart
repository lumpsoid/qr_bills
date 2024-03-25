import 'package:bill_repository/bill_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_bills/qr_scanner/bloc/scanner_bloc.dart';
import 'package:qr_bills/qr_scanner/qr_scanner.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) =>
            ScannerBloc(billRepository: context.read<BillRepository>()),
        child: const ScannerPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerBloc, ScannerState>(
        listenWhen: (previous, current) {
          return previous is ScannerLoaded &&
              current is ScannerLoaded &&
              previous.url != current.url;
        },
        listener: (context, state) {
          if (state is ScannerLoaded) {
            Navigator.of(context).pop();
          }
        },
        child: const ScannerScreen());
  }
}

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              formats: [BarcodeFormat.qrCode],
            ),
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.displayValue == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Value of the qr is NULL",
                        style: TextStyle(fontSize: 16.0)),
                    duration: Duration(seconds: 2),
                  ));
                } else {
                  context
                      .read<ScannerBloc>()
                      .add(ScannerQrScanned(url: barcode.displayValue!));
                }
              }
            },
          ),
          Positioned(
            bottom: 50,
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
