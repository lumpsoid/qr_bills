import 'package:equatable/equatable.dart';

enum BillType { qr, form, loading }

/// {@template bill}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class Bill extends Equatable {
  /// {@macro bill}
  Bill({
    required this.name,
    required this.body,
    required this.type,
    int? id,
    String? dateCreated,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch,
        dateCreated = dateCreated ?? DateTime.now().toIso8601String();

  Bill.fromMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        name = map['bill_name'] as String,
        type = BillType.values.firstWhere((e) => e.toString() == map['type']),
        dateCreated = map['date_created'] as String,
        body = map['qr'] != ''
            ? BillBodyQr(map['qr'] as String)
            : BillBodyForm(
                name: map['name'] as String,
                tags: map['tags'] as String,
                date: DateTime.fromMicrosecondsSinceEpoch(
                  int.parse(map['date'] as String),
                ),
                currency: map['currency'] as String,
                country: map['country'] as String,
                price: map['price'] as double,
                exchangeRate: map['exchange_rate'] as double,
              );

  Bill.loading()
      : this(
          name: '',
          body: const BillBodyQr(''),
          type: BillType.loading,
        );

  bool get isLoading => type == BillType.loading;

  final int id;
  final String name;
  final BillType type;
  final BillBody body;
  final String dateCreated;

  Future<Map<String, dynamic>> toMap() async {
    return {
      ...body.toDb(),
      'id': id,
      'type': type.toString(),
      'date_created': dateCreated,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        body,
        dateCreated,
        name,
      ];
}

abstract class BillBody extends Equatable {
  Map<String, dynamic> toDb();
  Map<String, dynamic> getPostBody({required bool force});
  String status();
  String getUrl();
}

class BillBodyQr implements BillBody {
  const BillBodyQr(this.url);

  final String url;

  @override
  Map<String, dynamic> getPostBody({required bool force}) {
    return {'link': url, 'force': force};
  }

  @override
  String status() {
    return url;
  }

  @override
  String getUrl() {
    return url;
  }

  @override
  Map<String, dynamic> toDb() {
    return {
      'qr': url,
      'name': '',
      'tags': '',
      'date': '',
      'currency': '',
      'country': '',
      'price': 0.0,
      'exchange_rate': 0.0,
    };
  }

  BillBodyQr copyWith(String? url) {
    return BillBodyQr(url ?? this.url);
  }

  @override
  List<Object> get props => [url];

  @override
  bool get stringify => true;
}

class BillBodyForm implements BillBody {
  BillBodyForm({
    required this.name,
    required this.tags,
    required this.date,
    required this.currency,
    required this.country,
    required this.price,
    required this.exchangeRate,
  });
  final String name;
  final String tags;
  final DateTime date;
  final String currency;
  final String country;
  final double price;
  final double exchangeRate;

  @override
  Map<String, dynamic> getPostBody({required bool force}) {
    return {
      'name': name,
      'date':
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'price': price,
      'currency': currency,
      'country': country,
      'tags': tags,
      'exchange_rate': exchangeRate,
      'force': force,
    };
  }

  @override
  String status() {
    return name;
  }

  @override
  String getUrl() {
    return '?name=$name&'
        "date=${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}&"
        'price=$price'
        'currency=$currency&'
        'country=$country&'
        'tags=$tags&'
        'exchange-rate=$exchangeRate';
  }

  @override
  Map<String, dynamic> toDb() {
    return {
      'qr': '',
      'name': name,
      'tags': tags,
      'date': date.microsecondsSinceEpoch.toString(),
      'currency': currency,
      'country': country,
      'price': price,
      'exchange_rate': exchangeRate,
    };
  }

  BillBodyForm copyWith({
    String? name,
    String? tags,
    DateTime? date,
    String? currency,
    String? country,
    double? price,
    double? exchangeRate,
  }) {
    return BillBodyForm(
      name: name ?? this.name,
      tags: tags ?? this.tags,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      price: price ?? this.price,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }

  @override
  List<Object?> get props => [
        name,
        tags,
        date,
        currency,
        country,
        price,
        exchangeRate,
      ];

  @override
  bool get stringify => true;
}
