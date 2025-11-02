// ignore_for_file: slash_for_doc_comments

import 'package:dio/dio.dart';

import 'api.service.dart';

class GatewayService {
  static final GatewayService _instance = GatewayService._internal();
  final apiService = ApiService();

  factory GatewayService() => _instance;

  GatewayService._internal();

  /******************
   *   Bank Apis    *
   ******************/

  Future<dynamic> createBank(
    String name,
    String accountName,
    String accountNumber,
    dynamic access,
  ) async {
    return apiService.post('/bank', {
      'name': name,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'access': access,
    });
  }

  Future<Response> getBanks() async {
    return await apiService.get('bank');
  }

  Future<dynamic> deleteBank(String id) async {
    await apiService.delete('bank/$id');
  }
}
