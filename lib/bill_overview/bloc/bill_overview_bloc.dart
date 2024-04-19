import 'package:bill_repository/bill_repository.dart';
import 'package:bill_rest_api/bill_rest_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bill/bill.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart';

part 'bill_overview_event.dart';
part 'bill_overview_state.dart';

class BillOverviewBloc extends Bloc<BillOverviewEvent, BillOverviewState> {
  BillOverviewBloc({required BillRepository billRepository})
      : _billRepository = billRepository,
        super(const BillOverviewState()) {
    on<BillOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<BillOverviewSettingsRequested>(_onSettingsRequested);
    on<BillOverviewServerUrlChanged>(_onServerUrlChange);
    on<BillOverviewServerUrlSubmit>(_onServerUrlSubmit);
    on<BillOverviewDeleteBill>(_onBillDelete);
    on<BillOverviewSendBill>(_onBillSend);
    on<BillOverviewLaunchUrl>(_onUrlLaunch);
  }

  final BillRepository _billRepository;

  Future<void> _onSubscriptionRequested(
    BillOverviewSubscriptionRequested event,
    Emitter<BillOverviewState> emit,
  ) async {
    emit(state.copyWith(status: BillOverviewStatus.loading));

    await emit.forEach<List<Bill>>(
      _billRepository.getBills(),
      onData: (bills) => state.copyWith(
        status: BillOverviewStatus.loaded,
        bills: bills,
      ),
      onError: (_, __) => state.copyWith(
        status: BillOverviewStatus.error,
        message: 'Error loading bills',
      ),
    );
  }

  Future<void> _onServerUrlChange(
    BillOverviewServerUrlChanged event,
    Emitter<BillOverviewState> emit,
  ) async {
    if (state.status != BillOverviewStatus.loaded) return;
    emit(state.copyWith(serverUrl: event.url));
  }

  Future<void> _onServerUrlSubmit(
    BillOverviewServerUrlSubmit event,
    Emitter<BillOverviewState> emit,
  ) async {
    if (state.status != BillOverviewStatus.loaded) return;
    if (state.serverUrl.isEmpty) return;
    await _billRepository.setServerUrl(state.serverUrl);
  }

  Future<void> _onSettingsRequested(
    BillOverviewSettingsRequested event,
    Emitter<BillOverviewState> emit,
  ) async {
    final serverUrl = await _billRepository.getServerUrl();
    emit(state.copyWith(
      status: BillOverviewStatus.loaded,
      serverUrl: serverUrl,
    ));
  }

  Future<void> _onBillDelete(
    BillOverviewDeleteBill event,
    Emitter<BillOverviewState> emit,
  ) async {
    if (state.status != BillOverviewStatus.loaded) return;
    try {
      await _billRepository.deleteBillLocaly(event.billId);
    } catch (_) {
      emit(state.copyWith(
        status: BillOverviewStatus.error,
        message: 'Error deleting bill. Bill was not found.',
      ));
      emit(state.copyWith(status: BillOverviewStatus.loaded));
    }
  }

  Future<void> _onBillSend(
    BillOverviewSendBill event,
    Emitter<BillOverviewState> emit,
  ) async {
    if (state.status != BillOverviewStatus.loaded) return;
    emit(state.copyWith(
      billsBeingSent: {
        ...state.billsBeingSent,
        event.bill.id,
      },
    ));
    final result = await _billRepository.sendBill(event.bill);

    switch (result['enum']) {
      case SendResult.success:
        final bill = result['bill'] as List<Map<String, dynamic>>;
        emit(state.copyWith(
          status: BillOverviewStatus.sendMessage,
          billResult: BillResult(
              message: 'Bill was added successfully.', billResult: bill),
        ));
        _billRepository.deleteBillLocaly(event.bill.id);
      case SendResult.socketException:
        emit(state.copyWith(
          status: BillOverviewStatus.sendMessage,
          billResult:
              const BillResult(message: 'Wrong server url. May be port.'),
        ));
      case SendResult.parseError:
        emit(state.copyWith(
          status: BillOverviewStatus.sendMessage,
          billResult: const BillResult(message: 'Site parse failed.'),
        ));
      case SendResult.duplicates:
        final bill = result['bill'] as List<Map<String, dynamic>>;
        emit(state.copyWith(
          status: BillOverviewStatus.sendMessage,
          billResult: BillResult(
              message: 'Duplicate was found in the Database.',
              billResult: bill),
        ));
      case SendResult.error:
        emit(state.copyWith(
          status: BillOverviewStatus.sendMessage,
          billResult: const BillResult(
              message:
                  'SendResult.error was received. This should not happen.'),
        ));
      case SendResult.typeMismatch:
        emit(state.copyWith(
          status: BillOverviewStatus.sendMessage,
          billResult:
              const BillResult(message: 'Server sent not a valid json.'),
        ));
      default:
        emit(state.copyWith(
          status: BillOverviewStatus.sendMessage,
          billResult: const BillResult(
              message: 'It is more absurd then SendResult.error.'),
        ));
    }
    final billsBeingSent = {...state.billsBeingSent};
    billsBeingSent.remove(event.bill.id);
    emit(state.copyWith(
      status: BillOverviewStatus.loaded,
      billsBeingSent: billsBeingSent,
    ));
  }

  Future<void> _onUrlLaunch(
    BillOverviewLaunchUrl event,
    Emitter<BillOverviewState> emit,
  ) async {
    if (state.status != BillOverviewStatus.loaded) return;
    final Uri urlParsed = Uri.parse(event.url);
    try {
      await launchUrl(urlParsed);
    } catch (_) {
      emit(state.copyWith(
        status: BillOverviewStatus.error,
        message: 'Broken url: $urlParsed',
      ));
      emit(state.copyWith(status: BillOverviewStatus.loaded));
    }
  }
}
