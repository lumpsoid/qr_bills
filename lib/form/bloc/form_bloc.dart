import 'package:bill/bill.dart';
import 'package:bill_repository/bill_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormBlocState> {
  FormBloc({required BillRepository billRepository})
      : _billRepository = billRepository,
        super(FormInitial()) {
    on<FormInit>(_onInit);
    on<FormBillAdd>(_onBillAdd);
    on<FormNameChanged>(_onNameChanged);
    on<FormTagsChanged>(_onTagsChanged);
    on<FormDateChanged>(_onDateChanged);
    on<FormPriceChanged>(_onPriceChanged);
    on<FormCurrencyChanged>(_onCurrencyChanged);
  }
  final BillRepository _billRepository;

  Future<void> _onInit(
    FormInit event,
    Emitter<FormBlocState> emit,
  ) async {
    emit(FormLoading());
    // TODO change from localApi request to restApi
    final currencyList = await _billRepository.getCurrences();
    if (currencyList.isEmpty) {
      currencyList.add('rsd');
    }
    final stateLoaded = FormLoaded.empty(DateTime.now());
    emit(stateLoaded.copyWith(currencyList: currencyList));
  }

  Future<void> _onBillAdd(
    FormBillAdd event,
    Emitter<FormBlocState> emit,
  ) async {
    try {
      if (state is FormLoaded) {
        final stateLoaded = state as FormLoaded;
        final body = BillBodyForm(
          name: stateLoaded.name,
          tags: stateLoaded.tags,
          date: stateLoaded.date,
          currency: stateLoaded.currency,
          country: stateLoaded.country,
          price: stateLoaded.price,
          exchangeRate: stateLoaded.exchangeRate,
        );
        await _billRepository.addBillLocaly(body, BillType.form);
      }
      emit(FormSuccess());
      emit(FormLoaded.empty(DateTime.now()));
    } catch (e) {
      emit(FormError());
    }
  }

  Future<void> _onNameChanged(
    FormNameChanged event,
    Emitter<FormBlocState> emit,
  ) async {
    if (state is FormLoaded) {
      final stateLoaded = state as FormLoaded;
      emit(stateLoaded.copyWith(name: event.name));
    }
  }

  Future<void> _onTagsChanged(
    FormTagsChanged event,
    Emitter<FormBlocState> emit,
  ) async {
    if (state is FormLoaded) {
      final stateLoaded = state as FormLoaded;
      emit(stateLoaded.copyWith(tags: event.tags));
    }
  }

  Future<void> _onDateChanged(
    FormDateChanged event,
    Emitter<FormBlocState> emit,
  ) async {
    if (state is FormLoaded) {
      final stateLoaded = state as FormLoaded;
      emit(stateLoaded.copyWith(date: event.date));
    }
  }

  Future<void> _onPriceChanged(
    FormPriceChanged event,
    Emitter<FormBlocState> emit,
  ) async {
    if (state is FormLoaded) {
      final stateLoaded = state as FormLoaded;
      emit(stateLoaded.copyWith(price: event.price));
    }
  }

  Future<void> _onCurrencyChanged(
    FormCurrencyChanged event,
    Emitter<FormBlocState> emit,
  ) async {
    if (state is FormLoaded) {
      final stateLoaded = state as FormLoaded;
      emit(stateLoaded.copyWith(currency: event.currency));
    }
  }
}
