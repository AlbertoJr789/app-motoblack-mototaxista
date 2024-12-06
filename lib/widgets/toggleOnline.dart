import 'dart:async';
import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class ToggleOnline extends StatefulWidget {
  const ToggleOnline({super.key});

  @override
  State<ToggleOnline> createState() => _ToggleOnlineState();
}

class _ToggleOnlineState extends State<ToggleOnline> {
  bool _online = false;

  late ActivityController _controller;
  late StreamSubscription _stream;

  void _toggleOnline(b) async {
    if (b) {
      await _controller.getOnline();
      await _stream.cancel();
      await _listenOnline();
    } else {
      await _controller.getOffline();
      await _stream.cancel();
    }
  }

   _listenOnline() async {
    Agent.getUuid().then((value) {
      print('mimde');
      print(value);
      if (value.isNotEmpty) {
          _stream = FirebaseFirestore.instance.collection('availableAgents').doc(value).snapshots().listen((querySnapshot) {
            print(querySnapshot);
            if(querySnapshot.exists){
              setState(() {
                _online = true;
              });
            }else{
              print('nao existe,cancela');
              Agent.setUuid('');
              _stream.cancel();
              setState(() {
                _online = false;
              });
            }
          });
      }
    });
  }

  @override
  initState() {
    super.initState();
    _listenOnline();  
  }

  @override
  Widget build(BuildContext context) {
    _controller = ActivityController(context);
    return AnimatedToggleSwitch<bool>.dual(
      current: _online,
      first: false,
      second: true,
      spacing: 45.0,
      animationDuration: const Duration(milliseconds: 600),
      style: const ToggleStyle(
        borderColor: Colors.transparent,
        indicatorColor: Colors.white,
        backgroundColor: Colors.amber,
      ),
      customStyleBuilder: (context, local, global) => ToggleStyle(
          backgroundGradient: LinearGradient(
        colors: const [Colors.green, Colors.red],
        stops: [
          global.position - (1 - 2 * max(0, global.position - 0.5)) * 0.5,
          global.position + max(0, 2 * (global.position - 0.5)) * 0.5,
        ],
      )),
      borderWidth: 6.0,
      height: 60.0,
      loadingIconBuilder: (context, global) => CupertinoActivityIndicator(
          color: Color.lerp(Colors.red, Colors.green, global.position)),
      onChanged: _toggleOnline,
      iconBuilder: (value) => value
          ? const Icon(Icons.power_outlined, color: Colors.green, size: 32.0)
          : const Icon(Icons.power_settings_new_rounded,
              color: Colors.red, size: 32.0),
      textBuilder: (value) => Center(
          child: Text(
        value ? 'On' : 'Off',
        style: const TextStyle(
            color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.w600),
      )),
    );
  }


  @override
  void dispose() {
    super.dispose();
    _stream.cancel();
  }

}
