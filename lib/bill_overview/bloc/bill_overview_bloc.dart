import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bill/bill.dart';
import 'package:equatable/equatable.dart';

part 'bill_overview_event.dart';
part 'bill_overview_state.dart';

class BillOverviewBloc extends Bloc<BillOverviewEvent, BillOverviewState> {
  BillOverviewBloc() : super(BillOverviewInitial()) {
    on<BillOverviewEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
  Future<void> _onFetchAll(int startingIndex) async {
    if (_pagesBeingFetched.contains(startingIndex)) {
      return;
    }

    _pagesBeingFetched.add(startingIndex);
    final BillPage page = await _dbHelper.fetchBills(startingIndex);
    _pagesBeingFetched.remove(startingIndex);

    if (!page.hasNext) {
      itemCount = startingIndex + page.items.length;
    }

    _bills.addAll(page.items);
    // _pruneCache(startingIndex);

    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> _onAddBill(BillBody body, BillType type) async {
    Bill bill = Bill(body: body, type: type);
    _dbHelper.insertBill(bill);

    if (itemCount != null) {
      _bills.add(bill);
      itemCount = itemCount! + 1;
    }
    notifyListeners();
  }

  Future<void> _onDeleteBill(int index) async {
    Bill bill = _bills.removeAt(index);
    itemCount = itemCount! - 1;
    notifyListeners();
    _dbHelper.deleteBill(bill.id);
  }

  bool isOnSend(int id) {
    return _billsBeingSent.contains(id);
  }

  void startSend(int id) {
    _billsBeingSent.add(id);
    notifyListeners();
  }

  void stopSend(int id) {
    _billsBeingSent.remove(id);
    notifyListeners();
  }
}
