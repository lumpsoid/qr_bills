import 'package:bill/bill.dart';
import 'package:bill_rest_api/bill_rest_api.dart';
import 'package:bill_sqflite_api/bill_sqflite_api.dart';
import 'package:settings_shared_api/settings_shared_api.dart';

/// {@template bill_repository}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class BillRepository {
  /// {@macro bill_repository}
  const BillRepository({
    required BillSqfliteApi localApi,
    required BillRestApi restApi,
    required SettingsSharedApi settingsApi,
  })  : _localApi = localApi,
        _restApi = restApi,
        _settingsApi = settingsApi;

  final BillSqfliteApi _localApi;
  final BillRestApi _restApi;
  final SettingsSharedApi _settingsApi;

  Future<List<Bill>> fetchAllBills() async {
    final bills = await _localApi.fetchAllBills();
    return bills;
  }

  Future<void> addBillLocaly(BillBody body, BillType type) async {
    final bill = Bill(body: body, type: type);
    await _localApi.insertBill(bill);
  }

  Future<void> deleteBillLocaly(int id) async {
    await _localApi.deleteBill(id);
  }

  Future<void> sendBill(Bill bill) async {
    final settings = _settingsApi.settings;
    if (bill.type == BillType.qr) {
      await _restApi.sendQr(settings.serverUrl, bill);
    } else {
      await _restApi.sendForm(settings.serverUrl, bill);
    }
    await _localApi.deleteBill(bill.id);
  }
}
