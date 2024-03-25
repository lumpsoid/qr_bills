import 'package:bill/bill.dart';
import 'package:bill_repository/bill_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

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
    if (state is ScannerLoaded && (state as ScannerLoaded).url != event.url) {
      _billRepository.addBillLocaly(BillBodyQr(event.url), BillType.qr);
    }
    emit(ScannerLoaded(url: event.url));
  }
}
