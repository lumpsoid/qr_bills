import 'package:bill_rest_api/bill_rest_api.dart';
import 'package:bill_sqflite_api/bill_sqflite_api.dart';
import 'package:flutter/widgets.dart';
import 'package:settings_shared_api/settings_shared_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qr_bills/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsApi = SettingsSharedApi(
    plugin: await SharedPreferences.getInstance(),
  );
  final billsLocalApi = BillSqfliteApi()..initDb();
  const billsRestApi = BillRestApi();

  bootstrap(
    settingsApi: settingsApi,
    billSqfliteApi: billsLocalApi,
    billRestApi: billsRestApi,
  );
}
