import 'package:bill/bill.dart';
import 'package:bill_repository/bill_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:username_generator/username_generator.dart';

part 'form_event.dart';
part 'form_state.dart';

class BillFormBloc extends Bloc<FormEvent, BillFormState> {
  BillFormBloc({required BillRepository billRepository})
      : _billRepository = billRepository,
        super(BillFormInitial()) {
    on<FormInit>(_onInit);
    on<FormBillAdd>(_onBillAdd);
    on<FormNameChanged>(_onNameChanged);
    on<FormTagsChanged>(_onTagsChanged);
    on<FormDateChanged>(_onDateChanged);
    on<FormPriceChanged>(_onPriceChanged);
    on<FormExchangeRateChanged>(_onExchangeRateChanged);
    on<FormCurrencyChanged>(_onCurrencyChanged);
  }
  final BillRepository _billRepository;

  Future<void> _onInit(
    FormInit event,
    Emitter<BillFormState> emit,
  ) async {
    emit(BillFormLoading());
    final currencyList = await _billRepository.getCurrencies();
    final tagsList = await _billRepository.getTags();
    final stateLoaded = BillFormLoaded.empty(DateTime.now());
    emit(stateLoaded.copyWith(currencyList: currencyList, tagsList: tagsList));
  }

  Future<void> _onBillAdd(
    FormBillAdd event,
    Emitter<BillFormState> emit,
  ) async {
    try {
      if (state is BillFormLoaded) {
        final stateLoaded = state as BillFormLoaded;
        final body = BillBodyForm(
          name: stateLoaded.name,
          tags: stateLoaded.tags,
          date: stateLoaded.date,
          currency: stateLoaded.currency,
          country: stateLoaded.country,
          price: stateLoaded.price,
          exchangeRate: stateLoaded.exchangeRate,
        );
        await _billRepository.addBillLocaly(
          Bill(
            type: BillType.form,
            body: body,
            name: UsernameGenerator().generateRandom(),
          ),
        );
      }
      emit(BillFormSuccess());
      emit(BillFormLoaded.empty(DateTime.now()));
    } catch (e) {
      emit(BillFormError());
    }
  }

  Future<void> _onNameChanged(
    FormNameChanged event,
    Emitter<BillFormState> emit,
  ) async {
    if (state is BillFormLoaded) {
      final stateLoaded = state as BillFormLoaded;
      emit(stateLoaded.copyWith(name: event.name));
    }
  }

  Future<void> _onTagsChanged(
    FormTagsChanged event,
    Emitter<BillFormState> emit,
  ) async {
    if (state is BillFormLoaded) {
      final stateLoaded = state as BillFormLoaded;
      emit(stateLoaded.copyWith(tags: event.tags));
    }
  }

  Future<void> _onDateChanged(
    FormDateChanged event,
    Emitter<BillFormState> emit,
  ) async {
    if (state is BillFormLoaded) {
      final stateLoaded = state as BillFormLoaded;
      emit(stateLoaded.copyWith(date: event.date));
    }
  }

  Future<void> _onPriceChanged(
    FormPriceChanged event,
    Emitter<BillFormState> emit,
  ) async {
    if (state is BillFormLoaded) {
      final stateLoaded = state as BillFormLoaded;
      final price = double.tryParse(event.price) ?? 0.0;
      emit(stateLoaded.copyWith(price: price));
    }
  }

  Future<void> _onExchangeRateChanged(
    FormExchangeRateChanged event,
    Emitter<BillFormState> emit,
  ) async {
    if (state is BillFormLoaded) {
      final stateLoaded = state as BillFormLoaded;
      final rate = double.tryParse(event.rate) ?? 0.0;
      emit(stateLoaded.copyWith(exchangeRate: rate));
    }
  }

  Future<void> _onCurrencyChanged(
    FormCurrencyChanged event,
    Emitter<BillFormState> emit,
  ) async {
    if (state is BillFormLoaded) {
      final stateLoaded = state as BillFormLoaded;
      emit(stateLoaded.copyWith(currency: event.currency));
    }
  }
}
