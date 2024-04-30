import 'dart:convert';
import 'dart:io';

import 'package:bill/bill.dart';
import 'package:http/http.dart';

enum SendResult {
  success,
  error,
  duplicates,
  socketException,
  typeMismatch,
}

/// {@template bill_rest_api}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class BillRestApi {
  /// {@macro bill_rest_api}
  const BillRestApi();

  static const String serverApi = '/api/flutter';

  List<Map<String, dynamic>> _parseBillList(List<dynamic> billList) {
    final parsedList = <Map<String, dynamic>>[];
    for (final bill in billList) {
      if (bill is Map<String, dynamic>) {
        parsedList.add(bill);
      }
    }
    return parsedList;
  }

  Map<String, dynamic> parseResponse(String source) {
    final jsonResponse = jsonDecode(source) as Map<String, dynamic>;
    final message = jsonResponse['message'] as String;
    switch (jsonResponse['success'] as String) {
      case 'error':
        return {
          'enum': SendResult.error,
          'message': message,
          'bill': [],
        };
      case 'success':
        return {
          'enum': SendResult.success,
          'bill': _parseBillList(jsonResponse['bill'] as List<dynamic>),
          'message': message,
        };
      case 'duplicates':
        return {
          'enum': SendResult.duplicates,
          'bill': _parseBillList(jsonResponse['bill'] as List<dynamic>),
          'message': message,
        };
      default:
        return {
          'enum': SendResult.error,
          'message': message,
          'bill': [],
        };
    }
  }

  Future<Map<String, dynamic>> sendQr(String serverUrl, Bill bill) async {
    Response response;
    final urlServer = Uri.http(serverUrl, '$serverApi/qr');

    final postBody = bill.body.getPostBody(force: false);
    try {
      response = await post(
        urlServer,
        body: jsonEncode(postBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } on SocketException catch (_) {
      return {'enum': SendResult.socketException, 'bill': null};
    } catch (e) {
      rethrow;
    }
    if (response.headers['content-type'] != 'application/json') {
      return {'enum': SendResult.typeMismatch, 'bill': null};
    }
    final result = parseResponse(response.body);
    return result;
  }

  Future<Map<String, dynamic>> sendForm(String serverUrl, Bill bill) async {
    Response response;
    final urlServer = Uri.http(serverUrl, '$serverApi/form');

    final postBody = bill.body.getPostBody(force: false);
    try {
      response = await post(
        urlServer,
        body: jsonEncode(postBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } on SocketException catch (_) {
      return {'enum': SendResult.socketException, 'bill': null};
    } catch (e) {
      rethrow;
    }
    if (response.headers['content-type'] != 'application/json') {
      return {'enum': SendResult.typeMismatch, 'bill': null};
    }

    final result = parseResponse(response.body);
    return result;
  }

  Future<List<String>> getCurrencies(String serverUrl) async {
    Response response;
    final urlServer = Uri.http(serverUrl, '$serverApi/currencies');
    try {
      response = await get(
        urlServer,
      );
    } catch (e) {
      rethrow;
    }

    if (response.statusCode != 200) {
      return [];
    }
    final result = jsonDecode(response.body) as List<dynamic>;
    final stringList = result
        .map<String>(
          (element) => element.toString(),
        )
        .toList();

    return stringList;
  }

  Future<List<String>> getTags(String serverUrl) async {
    Response response;
    final urlServer = Uri.http(serverUrl, '$serverApi/tags');
    try {
      response = await get(
        urlServer,
      );
    } catch (e) {
      rethrow;
    }

    if (response.statusCode != 200) {
      return [];
    }
    final result = jsonDecode(response.body) as List<dynamic>;
    final stringList = result
        .map<String>(
          (element) => element.toString(),
        )
        .toList();
    return stringList;
  }
}
