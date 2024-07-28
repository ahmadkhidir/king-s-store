import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sales_ai_examples/src/paystack/utils/helpers.dart';
import 'package:sales_ai_examples/src/paystack/utils/models.dart';

class PaystackRepository {
  final Dio _dio;
  PaystackRepository({required String secretKey})
      : _dio = Dio(
          BaseOptions(
            baseUrl: TransactionURLs.baseURL,
            headers: {
              "Authorization": "Bearer $secretKey",
            },
            validateStatus: (status) => true,
          ),
        );

  Future<TransactionModel> initializeTransaction(
      String email, String amount) async {
    try {
      final response = await _dio.post(TransactionURLs.initialize, data: {
        "email": email,
        "amount": amount,
      });
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return TransactionModel(
          url: data["authorization_url"],
          accessCode: data["access_code"],
          reference: data["reference"],
        );
      } else {
        debugPrint(response.data);
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyPayment(String reference) async {
    try {
      final response = await _dio.post("${TransactionURLs.verify}/$reference");
      if (response.statusCode == 200) {
        final String status = response.data["data"]["status"];
        debugPrint(status);
        return status == "success" ? true : false;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
