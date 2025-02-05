
import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
        body: Center(
      child: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse("${ApiClient.instance.baseUrl}/registerAgent"),
        ),
        initialOptions: InAppWebViewGroupOptions(
          
          crossPlatform: InAppWebViewOptions(clearCache: true,javaScriptEnabled: true,),
        ),
        // onWebViewCreated: (controller) {},
        onUpdateVisitedHistory: (controller, url, androidIsReload) {
          if (url!.path == '/login') {
            //usuario logou,redirecionado pra rota raiz
            Navigator.of(context).pop();
            FToast().init(context).showToast(
                child: MyToast(
                  msg: const Text(
                    'Cadastro efetuado com sucesso!',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  color: Colors.greenAccent,
                ),
                gravity: ToastGravity.BOTTOM,
                toastDuration: const Duration(seconds: 2));
          }
        },
      ),
    ));
  }
}
