part of 'form_bloc.dart';

sealed class FormBlocState extends Equatable {
  const FormBlocState();

  @override
  List<Object> get props => [];
}

final class FormInitial extends FormBlocState {}

final class FormLoading extends FormBlocState {}

final class FormError extends FormBlocState {}

final class FormSuccess extends FormBlocState {}

final class FormLoaded extends FormBlocState {
  const FormLoaded(
      {required this.name,
      required this.tags,
      required this.date,
      required this.currency,
      required this.country,
      required this.price,
      required this.exchangeRate,
      this.currencyList = const []});

  const FormLoaded.empty(this.date)
      : name = '',
        tags = '',
        currency = 'rsd',
        country = 'serbia',
        price = 0,
        exchangeRate = 1,
        currencyList = const [];

  final String name;
  final String tags;
  final DateTime date;
  final String currency;
  final String country;
  final double price;
  final double exchangeRate;
  final List<String> currencyList;

  FormLoaded copyWith(
      {String? name,
      String? tags,
      DateTime? date,
      String? currency,
      String? country,
      double? price,
      double? exchangeRate,
      List<String>? currencyList}) {
    return FormLoaded(
        name: name ?? this.name,
        tags: tags ?? this.tags,
        date: date ?? this.date,
        currency: currency ?? this.currency,
        country: country ?? this.country,
        price: price ?? this.price,
        exchangeRate: exchangeRate ?? this.exchangeRate,
        currencyList: currencyList ?? this.currencyList);
  }

  @override
  List<Object> get props =>
      [name, tags, date, currency, country, price, exchangeRate, currencyList];
}
