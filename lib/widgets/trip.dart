import 'dart:async';
import 'dart:typed_data';

import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/widgets/assets.dart';
import 'package:app_motoblack_mototaxista/widgets/tripIcon.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  late ActivityController _controller;
  late StreamSubscription _stream;
  final List<Marker> _markers = [];
  BitmapDescriptor? _passengerIcon;

  @override
  initState() {
    super.initState();
    _controller = Provider.of<ActivityController>(context, listen: false);
    _createMarkerIcon();
    _listenTrip();
  }

  void _createMarkerIcon() async {
    try {
      final String url = '${ApiClient.instance.baseUrl}/api/marker/${_controller.currentActivity!.passenger!.userId}';
      _passengerIcon = await getMarkerImageFromUrl(url,targetWidth: 120);
      setState(() {});
    } catch (e) {
      _passengerIcon = BitmapDescriptor.defaultMarker;
      setState(() {});
    }
  }

  _listenTrip() {
    _stream = FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .onValue
        .listen((querySnapshot) {
      if (querySnapshot.snapshot.exists) {
        final data = querySnapshot.snapshot.value as Map;
        
        if(data['cancelled'] == true && data['whoCancelled'] == 'p'){
          _controller.cancelActivity(alreadyCancelled: true);
          _stream.cancel();
             showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Corrida cancelada pelo passageiro !'),
                      SizedBox(height: 10,),
                      Text('Motivo: ${data['cancellingReason']}'),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
          return;
        }
        
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('passenger'),
          position: LatLng(
              data['passenger']['latitude'],
              data['passenger']['longitude']),
          icon: _passengerIcon!,
          infoWindow: const InfoWindow(
            title: 'Seu Passageiro',
          ),
        ));
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          initialCameraPosition: CameraPosition(
              target: LatLng(_controller.currentActivity!.origin.latitude!,
                  _controller.currentActivity!.origin.longitude!),
              zoom: 16),
          markers: Set<Marker>.of(_markers),
        ),
        Positioned(
            bottom: 10,
            right: MediaQuery.of(context).size.width * 0.33,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _endTripDialog,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                label: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.red), // Set the background color of the icon
                ),
              ),
            )),
      ],
    );
  }

   void _endTripDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tem certeza que deseja cancelar a corrida ?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelTripDialog();
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  TextEditingController _cancellingReason = TextEditingController();
  final _formCancelamentoKey = GlobalKey<FormState>();
  bool _cancelling = false;

  void _cancelTripDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Form(
              key: _formCancelamentoKey,
              child: Column(
              children: [
                Text('Insira o motivo do cancelamento: '),
                TextFormField(
                  controller: _cancellingReason,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Motivo não pode estar vazio';
                    }
                    return null;
                  },
                )
              ],
            )),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (_formCancelamentoKey.currentState!.validate()) {
                    setState(() {
                      _cancelling = true;
                    });
                    final ret = await _controller.cancelActivity(
                      trip: _controller.currentActivity!,
                      reason: _cancellingReason.text,
                    );
                    setState(() {
                      _cancelling = false;
                    });
                    if (!ret) {
                      FToast().init(context).showToast(
                          child: MyToast(
                            msg: const Text('Houve um erro ao cancelar sua corrida! Tente novamente.',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            icon: const Icon(
                              Icons.error,
                              color: Colors.white,
                            ),
                            color: Colors.redAccent,
                          ),
                          gravity: ToastGravity.BOTTOM,
                          toastDuration: const Duration(seconds: 5));
                    }else{
                      _stream.cancel();
                      Navigator.pop(ctx);
                    }
                  }
                },
                child: _cancelling ? Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary,),
                ): Text('Cancelar'),
              ),
            ],
          );
        }
      ),
    );
  }


}
