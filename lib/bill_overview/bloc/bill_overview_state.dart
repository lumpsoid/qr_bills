part of 'bill_overview_bloc.dart';

enum BillOverviewStatus { initial, loading, loaded, error, sendMessage }

final class BillResult extends Equatable {
  const BillResult({this.billResult = const [{}], this.message = ''});

  final List<Map<String, dynamic>> billResult;
  final String message;

  @override
  List<Object> get props => [billResult, message];
}

final class BillOverviewState extends Equatable {
  const BillOverviewState(
      {this.status = BillOverviewStatus.initial,
      this.billResult = const BillResult(),
      this.bills = const [],
      this.billsBeingSent = const {},
      this.serverUrl = ''});

  final BillOverviewStatus status;
  final BillResult billResult;
  final List<Bill> bills;
  final Set<int> billsBeingSent;
  final String serverUrl;

  @override
  List<Object> get props =>
      [status, billResult, bills, billsBeingSent, serverUrl];

  BillOverviewState copyWith({
    BillOverviewStatus Function()? status,
    BillResult Function()? billResult,
    List<Bill> Function()? bills,
    Set<int> Function()? billsBeingSent,
    String Function()? serverUrl,
  }) {
    return BillOverviewState(
      status: status != null ? status() : this.status,
      billResult: billResult != null ? billResult() : this.billResult,
      bills: bills != null ? bills() : this.bills,
      billsBeingSent:
          billsBeingSent != null ? billsBeingSent() : this.billsBeingSent,
      serverUrl: serverUrl != null ? serverUrl() : this.serverUrl,
    );
  }
}
