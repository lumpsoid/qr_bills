import 'dart:async';
import 'dart:developer';

import 'package:bill_repository/bill_repository.dart';
import 'package:bill_rest_api/bill_rest_api.dart';
import 'package:bill_sqflite_api/bill_sqflite_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_bills/app/app.dart';
import 'package:qr_bills/app/app_bloc_observer.dart';
import 'package:settings_shared_api/settings_shared_api.dart';

void bootstrap({
  required SettingsSharedApi settingsApi,
  required BillSqfliteApi billSqfliteApi,
  required BillRestApi billRestApi,
}) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  final billRepository = BillRepository(
    localApi: billSqfliteApi,
    restApi: billRestApi,
    settingsApi: settingsApi,
  );

  runZonedGuarded(
    () => runApp(App(billsRepository: billRepository)),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
