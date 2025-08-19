// ignore_for_file: slash_for_doc_comments

import 'api.service.dart';

class GatewayService {
  static final GatewayService _instance = GatewayService._internal();
  final apiService = ApiService();

  factory GatewayService() => _instance;

  GatewayService._internal();

  /******************
   *   Bank Apis    *
   ******************/

  Future<dynamic> createBank(name, accountNumber) async {
    return apiService.post('/bank', {
      'name': name,
      'accountNumber': accountNumber,
    });
  }

  getBanks() async {
    return await apiService.get('bank');
  }

  Future<dynamic> deleteBank(String id) async {
    await apiService.delete('bank/$id');
  }
}
