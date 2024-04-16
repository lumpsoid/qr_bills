part of 'form_bloc.dart';

sealed class BillFormState extends Equatable {
  const BillFormState();

  @override
  List<Object> get props => [];
}

final class BillFormInitial extends BillFormState {}

final class BillFormLoading extends BillFormState {}

final class BillFormError extends BillFormState {}

final class BillFormSuccess extends BillFormState {}

final class BillFormLoaded extends BillFormState {
  const BillFormLoaded(
      {required this.name,
      required this.tags,
      required this.tagsList,
      required this.date,
      required this.currency,
      required this.country,
      required this.price,
      required this.exchangeRate,
      this.currencyList = const []});

  const BillFormLoaded.empty(this.date)
      : name = '',
        tags = '',
        tagsList = const [],
        currency = 'rsd',
        country = 'serbia',
        price = 0,
        exchangeRate = 1,
        currencyList = const [];

  final String name;
  final String tags;
  final List<String> tagsList;
  final DateTime date;
  final String currency;
  final String country;
  final double price;
  final double exchangeRate;
  final List<String> currencyList;

  BillFormLoaded copyWith({
    String? name,
    String? tags,
    DateTime? date,
    String? currency,
    String? country,
    double? price,
    double? exchangeRate,
    List<String>? currencyList,
    List<String>? tagsList,
  }) {
    return BillFormLoaded(
      name: name ?? this.name,
      tags: tags ?? this.tags,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      price: price ?? this.price,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      currencyList: currencyList ?? this.currencyList,
      tagsList: tagsList ?? this.tagsList,
    );
  }

  @override
  List<Object> get props => [
        name,
        tags,
        date,
        currency,
        country,
        price,
        exchangeRate,
        currencyList,
        tagsList
      ];
}
