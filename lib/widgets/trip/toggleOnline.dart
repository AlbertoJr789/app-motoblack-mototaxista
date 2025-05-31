import 'dart:async';
import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:app_motoblack_mototaxista/widgets/activity/activitySuggestion.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ToggleOnline extends StatefulWidget {
  const ToggleOnline({super.key});

  @override
  State<ToggleOnline> createState() => _ToggleOnlineState();
}

class _ToggleOnlineState extends State<ToggleOnline> {
  bool _online = false;
  String _uuid = '';
  bool _suggesting = false;
  bool _acceptingTrip = false;

  late ActivityController _controller;
  late StreamSubscription _stream;
  late StreamSubscription _locationListener;
  late Position _currentLocation;

  @override
  initState() {
    super.initState();
    _listenOnline();
    _listenLocation();
    _controller = Provider.of<ActivityController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
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

    void _toggleOnline(b) async {
    if (b) {
      _uuid = await _controller.getOnline();
      if (_uuid.isNotEmpty) {
        _online = true;
        _listenOnline();
        _listenLocation();
      } else {
        if(mounted){
          toastError(context, "Erro ao iniciar sessão. Tente novamente mais tarde");
        }
      }
      setState(() {});
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
      _stream = FirebaseDatabase.instance
          .ref('availableAgents')
          .child(_uuid)
          .onValue
          .listen((querySnapshot) {
        if (querySnapshot.snapshot.exists) {
          if (_online == false) {
            setState(() {
              _online = true;
            });
          }
          if (!_suggesting) {
            final data = querySnapshot.snapshot.value as Map;
            if (data.containsKey('trips')) {
                final trips = data['trips'];
                if (trips is Map) {
                  final tripSuggestion =
                    trips.entries.firstWhere(
                      (entry) => 
                      entry.value == false
                      ).key;
                if (tripSuggestion != null) {
                  _showTripSuggestion(tripSuggestion);
                }
              }
            }
          }
        } else {
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
      _currentLocation = position;
      if(_online){
          FirebaseDatabase.instance.ref('availableAgents').child(_uuid).update({
            'latitude': position.latitude,
            'longitude': position.longitude
          });
        }
      });
  }

  _showTripSuggestion(tripId) async {
    _suggesting = true;
    Activity? activity = await Activity.getApi(tripId);
    if (activity == null && _controller.currentActivity == null) {
       FirebaseDatabase.instance
          .ref('availableAgents')
          .child(_uuid)
          .child('trips')
          .child(tripId.toString())
          .set(true);
      _suggesting = false;
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: ActivitySuggestion(activity: activity!,currentLocation: _currentLocation),
          actions: [
            ElevatedButton(
              onPressed: () {
                _controller.refuseTrip(activity,_uuid);
                Navigator.pop(ctx);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.red), // Set the background color of the icon
              ),
              child: const Text(
                'Tô fora',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _acceptingTrip = true;
                });
                _controller.currentLocation = _currentLocation;
                bool ret = await _controller.acceptTrip(activity);
                if (!ret) {
                  setState(() {
                    _acceptingTrip = false;
                  });
                  toastError(context, 'Erro ao aceitar corrida, tente novamente.',);
                } else {
                  Navigator.pop(context);
                  toastSuccess(context, 'Aceite feito com sucesso, inicializando mapa...');
                }
              },
              child: _acceptingTrip
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    )
                  : const Text('Bora!'),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _stream.cancel();
  }
}
