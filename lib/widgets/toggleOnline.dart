import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToggleOnline extends StatefulWidget {
  const ToggleOnline({super.key});

  @override
  State<ToggleOnline> createState() => _ToggleOnlineState();
}

class _ToggleOnlineState extends State<ToggleOnline> {
  bool _online = false;

  late ActivityController _controller;

  void _toggleOnline(b) async {
    if(b){
       _online = await _controller.getOnline();
    }else{
       _online = await _controller.getOffline();
    }
    setState(() {
    });
  }

  @override
  initState() {
    super.initState();
    Agent.getUuid().then((value) {
      setState(() {
        _online = value.isNotEmpty;
      });
    });
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
}
