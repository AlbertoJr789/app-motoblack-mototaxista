import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/main.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:app_motoblack_mototaxista/screens/login.dart';
import 'package:app_motoblack_mototaxista/util/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {

  BuildContext context;

  LoginController(this.context);

  final ApiClient apiClient = ApiClient.instance;

  Future<bool> login(String user, String password) async {
    var response = null;
    try {
      response = await apiClient.dio.post(
        '/api/auth/login',
        options: Options(
            contentType: Headers.jsonContentType,
            headers: {'accept': 'application/json'}),
        data: {
          'name': user,
          'password': password,
          'type': 'A'
        },
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.data['token']);
      return true;
    } on DioException catch (e) {
      String message =  e.response?.data['message'] ?? e.toString();
      showAlert(context, "Erro ao realizar login", sol: "Verifique suas credenciais", error: message);
      return false;
    }
  }
  
  static logoff() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await Agent.removeUuid();
    navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) => Login()), (route) => false);
  }

}
