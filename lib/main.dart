import 'package:app_motoblack_mototaxista/firebase_options.dart';
import 'package:app_motoblack_mototaxista/screens/login.dart';
import 'package:app_motoblack_mototaxista/screens/main.dart';
import 'package:app_motoblack_mototaxista/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  await Permission.camera.request();

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
      throw 'Seu serviço de localização está desativado! Reative-o nas configurações do seu dispositivo.';
  }

  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw 'Permissão negada! Precisamos da sua permissão para obter sua localização automaticamente!';
  }
  
    //verifica se o usuário já logou
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = await prefs.getString('token');
  runApp(MyApp(login: token != null ? false : true));
}


class MyApp extends StatelessWidget {

  final bool? login;

  const MyApp({super.key,required this.login});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Moto Black',
      theme: kTheme,
      home:  login! ? const Login() : const Main(),
    );
  }
}