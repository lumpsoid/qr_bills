part of 'form_bloc.dart';

sealed class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object> get props => [];
}

final class FormInit extends FormEvent {
  const FormInit();
}

final class FormBillAdd extends FormEvent {
  const FormBillAdd();
}

final class FormNameChanged extends FormEvent {
  final String name;

  const FormNameChanged(this.name);

  @override
  List<Object> get props => [name];
}

final class FormTagsChanged extends FormEvent {
  final String tags;

  const FormTagsChanged(this.tags);

  @override
  List<Object> get props => [tags];
}

final class FormDateChanged extends FormEvent {
  final DateTime date;

  const FormDateChanged(this.date);

  @override
  List<Object> get props => [date];
}

final class FormPriceChanged extends FormEvent {
  final double price;

  const FormPriceChanged(this.price);

  @override
  List<Object> get props => [price];
}

final class FormCurrencyChanged extends FormEvent {
  final String currency;

  const FormCurrencyChanged(this.currency);

  @override
  List<Object> get props => [currency];
}
