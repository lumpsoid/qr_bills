import 'dart:async';

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

  Stream<List<Bill>> fetchAllBills() => _localApi.getBills();

  Future<void> addBillLocaly(BillBody body, BillType type) async {
    final bill = Bill(body: body, type: type);
    await _localApi.insertBill(bill);
  }

  Future<void> deleteBillLocaly(int id) async {
    await _localApi.deleteBill(id);
  }

  Future<Map<String, dynamic>> sendBill(Bill bill) async {
    final settings = _settingsApi.settings;
    Map<String, dynamic> result;
    if (bill.type == BillType.qr) {
      result = await _restApi.sendQr(settings.serverUrl, bill);
    } else {
      result = await _restApi.sendForm(settings.serverUrl, bill);
    }
    if (result['enum'] == SendResult.success) {
      await _localApi.deleteBill(bill.id);
    }
    return result;
  }

  Future<List<String>> getCurrences() async {
    final result = await _localApi.getCurrences();
    if (result.isNotEmpty) {
      return result;
    }
    final currenciesList = await _restApi.getCurrences();
    unawaited(_localApi.setCurrences(currenciesList));
    return currenciesList;
  }

  Future<String> getServerUrl() async => _settingsApi.settings.serverUrl;

  Future<void> setServerUrl(String url) async =>
      _settingsApi.updateServerUrl(url);
}
