
//generic function that shows a dialog
import 'package:flutter/material.dart';

void showAlert(BuildContext context,String message, {String? sol,String? error,Function? onPressed}) {
    String errorMessage = error != null ? 'Motivo do erro: ${error}\n\n': '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ops!'),
        content: Text("${message}\n\n${errorMessage}${sol}"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if(onPressed != null){
                onPressed();
              }
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }