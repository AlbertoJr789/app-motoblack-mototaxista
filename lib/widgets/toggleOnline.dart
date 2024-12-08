import 'dart:async';
import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';

class ToggleOnline extends StatefulWidget {
  const ToggleOnline({super.key});

  @override
  State<ToggleOnline> createState() => _ToggleOnlineState();
}

class _ToggleOnlineState extends State<ToggleOnline> {
  bool _online = false;
  String _uuid = '';

  late ActivityController _controller;
  late StreamSubscription _stream;
  late StreamSubscription _locationListener;

  void _toggleOnline(b) async {
    if (b) {
      _uuid = await _controller.getOnline();
      if(_uuid.isNotEmpty) _online = true;
      _listenOnline();
      _listenLocation();
    } else {
      _online = await _controller.getOffline();
      _stream.cancel();
      _locationListener.cancel(); 
      setState(() {});
    }
  }

   _listenOnline() async {
    if (_uuid.isEmpty) _uuid = await Agent.getUuid();
    if (_uuid.isNotEmpty) {
          _stream = FirebaseDatabase.instance.ref('availableAgents').child(_uuid).onValue.listen((querySnapshot) {
            if(querySnapshot.snapshot.exists){
              setState(() {
                _online = true;
              });
            }else{
              Agent.setUuid('');
              _stream.cancel();
              _locationListener.cancel();
              setState(() {
                _online = false;
              });
            }
          });
      }
  }

  _listenLocation() {
    _locationListener = Geolocator.getPositionStream().listen((Position position) {
      if(_online){
         FirebaseDatabase.instance.ref('availableAgents').child(_uuid).update({
          'latitude': position.latitude,
          'longitude': position.longitude
        });
      }
    });
  }

  @override
  initState() {
    super.initState();
    _listenOnline();  
    _listenLocation();
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
