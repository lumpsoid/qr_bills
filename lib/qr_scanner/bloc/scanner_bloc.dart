import 'package:bill/bill.dart';
import 'package:bill_repository/bill_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:username_generator/username_generator.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc({required BillRepository billRepository})
      : _billRepository = billRepository,
        super(ScannerInitial()) {
    on<ScannerQrScanned>(_onQrScanned);
  }

  final BillRepository _billRepository;

  Future<void> _onQrScanned(
    ScannerQrScanned event,
    Emitter<ScannerState> emit,
  ) async {
    final state = this.state;
    if (state is ScannerInitial) {
      _billRepository.addBillLocaly(Bill(
        type: BillType.qr,
        body: BillBodyQr(event.url),
        name: UsernameGenerator().generateRandom(),
      ));
    }
    emit(ScannerLoaded(url: event.url));
  }
}
