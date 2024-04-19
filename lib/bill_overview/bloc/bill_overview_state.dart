part of 'bill_overview_bloc.dart';

enum BillOverviewStatus { initial, loading, loaded, error, sendMessage }

final class BillResult extends Equatable {
  const BillResult({
    this.billResult = const [{}],
    this.message = '',
  });

  final List<Map<String, dynamic>> billResult;
  final String message;

  @override
  List<Object> get props => [
        billResult,
        message,
      ];
}

final class BillOverviewState extends Equatable {
  const BillOverviewState({
    this.status = BillOverviewStatus.initial,
    this.billResult = const BillResult(),
    this.bills = const <Bill>[],
    this.billsBeingSent = const <int>{},
    this.serverUrl = '',
    this.message = '',
  });

  final BillOverviewStatus status;
  final BillResult billResult;
  final List<Bill> bills;
  final Set<int> billsBeingSent;
  final String serverUrl;
  final String message;

  @override
  List<Object> get props => [
        status,
        billResult,
        bills,
        billsBeingSent,
        serverUrl,
        message,
      ];

  BillOverviewState copyWith({
    BillOverviewStatus? status,
    BillResult? billResult,
    List<Bill>? bills,
    Set<int>? billsBeingSent,
    String? serverUrl,
    String? message,
  }) {
    return BillOverviewState(
      status: status ?? this.status,
      billResult: billResult ?? this.billResult,
      bills: bills ?? this.bills,
      billsBeingSent: billsBeingSent ?? this.billsBeingSent,
      serverUrl: serverUrl ?? this.serverUrl,
      message: message ?? this.message,
    );
  }
}
