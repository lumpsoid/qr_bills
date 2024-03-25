part of 'bill_overview_bloc.dart';

sealed class BillOverviewEvent extends Equatable {
  const BillOverviewEvent();

  @override
  List<Object> get props => [];
}

final class BillOverviewSubscriptionRequested extends BillOverviewEvent {
  const BillOverviewSubscriptionRequested();
}

final class BillOverviewSettingsRequested extends BillOverviewEvent {
  const BillOverviewSettingsRequested();
}

final class BillOverviewUrlSubmit extends BillOverviewEvent {
  const BillOverviewUrlSubmit();
}

final class BillOverviewLaunchUrl extends BillOverviewEvent {
  const BillOverviewLaunchUrl(this.url);

  final String url;

  @override
  List<Object> get props => [url];
}

final class BillOverviewUrlCanceled extends BillOverviewEvent {
  const BillOverviewUrlCanceled();
}

final class BillOverviewOpenUrlEdit extends BillOverviewEvent {
  const BillOverviewOpenUrlEdit();
}

final class BillOverviewServerUrlChanged extends BillOverviewEvent {
  const BillOverviewServerUrlChanged(this.url);

  final String url;

  @override
  List<Object> get props => [url];
}

final class BillOverviewServerUrlSubmit extends BillOverviewEvent {
  const BillOverviewServerUrlSubmit();
}

final class BillOverviewDeleteBill extends BillOverviewEvent {
  const BillOverviewDeleteBill(this.billId);

  final int billId;

  @override
  List<Object> get props => [billId];
}

final class BillOverviewSendBill extends BillOverviewEvent {
  const BillOverviewSendBill(this.bill);

  final Bill bill;

  @override
  List<Object> get props => [bill];
}
