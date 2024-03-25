import 'dart:convert';
import 'dart:io';

import 'package:bill/bill.dart';
import 'package:http/http.dart';

enum SendResult {
  success,
  error,
  duplicates,
  socketException,
  parseError,
  typeMismatch
}

/// {@template bill_rest_api}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class BillRestApi {
  /// {@macro bill_rest_api}
  const BillRestApi();

  static const String serverApi = '/api/flutter';

  Map<String, dynamic> parseResponse(String source) {
    final jsonResponse = jsonDecode(source);
    switch (jsonResponse['success'] as String) {
      case 'parse_error':
        return {'enum': SendResult.parseError, 'bill': jsonResponse['bill']};
      case 'success':
        return {'enum': SendResult.success, 'bill': jsonResponse['bill']};
      case 'duplicates':
        return {'enum': SendResult.duplicates, 'bill': jsonResponse['bill']};
      default:
        return {'enum': SendResult.error, 'bill': jsonResponse['bill']};
    }
  }

  Future<Map<String, dynamic>> sendQr(String serverUrl, Bill bill) async {
    Response response;
    final urlServer = Uri.http(serverUrl, '$serverApi/qr');

    final postBody = bill.body.getPostBody(force: 'false');
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

    final postBody = bill.body.getPostBody(force: 'false');
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

  Future<List<String>> getCurrences() async {
    // TODO implement
    // TODO implement rest api endpoint
    throw UnimplementedError();
  }
}
