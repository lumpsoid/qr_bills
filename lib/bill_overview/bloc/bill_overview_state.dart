part of 'bill_overview_bloc.dart';

sealed class BillOverviewState extends Equatable {
  const BillOverviewState();

  @override
  List<Object> get props => [];
}

final class BillOverviewInitial extends BillOverviewState {}

final class BillOverviewLoaded extends BillOverviewState {
  final List<Bill> bills;
  final Set<int> billsBeingSent;

  const BillOverviewLoaded({required this.bills, required this.billsBeingSent});

  @override
  List<Object> get props => [bills, billsBeingSent];
}
