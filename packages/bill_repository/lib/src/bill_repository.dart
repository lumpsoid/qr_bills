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

  Stream<List<Bill>> getBills() => _localApi.getBills();

  Future<void> addBillLocaly(Bill bill) async {
    await _localApi.insertBill(bill);
  }

  Future<void> deleteBillLocaly(int id) async {
    await _localApi.deleteBill(id);
  }

  Future<Map<String, dynamic>> sendBill(Bill bill) async {
    final serverUrl = await getServerUrl();
    Map<String, dynamic> result;
    if (bill.type == BillType.qr) {
      result = await _restApi.sendQr(serverUrl, bill);
    } else {
      result = await _restApi.sendForm(serverUrl, bill);
    }
    return result;
  }

  Future<List<String>> getCurrencies() async {
    final result = await _localApi.getCurrencies();
    if (result.isNotEmpty) {
      return result;
    }
    final serverUrl = await getServerUrl();
    final currenciesList = await _restApi.getCurrencies(serverUrl);
    if (currenciesList.isNotEmpty) {
      unawaited(_localApi.setCurrencies(currenciesList));
    }
    return currenciesList;
  }

  Future<List<String>> getTags() async {
    final result = await _localApi.getTags();
    if (result.isNotEmpty) {
      return result;
    }
    final serverUrl = await getServerUrl();
    final tagsList = await _restApi.getTags(serverUrl);
    if (tagsList.isNotEmpty) {
      unawaited(_localApi.setTags(tagsList));
    }
    return tagsList;
  }

  Future<String> getServerUrl() async => _settingsApi.settings.serverUrl;

  Future<void> setServerUrl(String url) async =>
      _settingsApi.updateServerUrl(url);
}
