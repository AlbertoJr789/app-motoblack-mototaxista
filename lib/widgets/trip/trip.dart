import 'dart:async';
import 'dart:typed_data';

import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/toast.dart';
import 'package:app_motoblack_mototaxista/widgets/trip/tripIcon.dart';
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
  List<Polyline> _polylines = [];
  BitmapDescriptor? _passengerIcon;
  bool _showMap = true;

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

      _markers.add(Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(_controller.currentActivity!.origin.latitude!,
            _controller.currentActivity!.origin.longitude!),
        icon: await createFlagBitmapFromIcon(Icon(Icons.flag,color: Theme.of(context).colorScheme.secondary)),
        infoWindow: const InfoWindow(title: 'Ponto de partida'),
        ));
    
      _markers.add(Marker(
        markerId: const MarkerId('destiny'),
        position: LatLng(_controller.currentActivity!.destiny.latitude!,
            _controller.currentActivity!.destiny.longitude!),
        icon: await createFlagBitmapFromIcon(Icon(Icons.flag_circle_rounded,color: Theme.of(context).colorScheme.surface,)),
        infoWindow: const InfoWindow(title: 'Ponto de destino'),
        ));

      _polylines.add(Polyline(
        width: 4,
        polylineId: const PolylineId('origin-destiny'),
        points: [LatLng(_controller.currentActivity!.origin.latitude!,
            _controller.currentActivity!.origin.longitude!),
        LatLng(_controller.currentActivity!.destiny.latitude!,
            _controller.currentActivity!.destiny.longitude!)],
        color: Theme.of(context).colorScheme.secondary));

      setState(() {});
    } catch (e) {
      _passengerIcon = BitmapDescriptor.defaultMarker;
      setState(() {});
    }
  }

  _listenTrip() async {
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
        
        _markers.removeWhere((marker) => marker.markerId.value == 'passenger');
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
      fit: StackFit.expand,
      children: [
        if (_showMap)
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            polylines: Set<Polyline>.of(_polylines),
            initialCameraPosition: CameraPosition(
                target: LatLng(_controller.currentActivity!.origin.latitude!,
                    _controller.currentActivity!.origin.longitude!),
                zoom: 16),
            markers: Set<Marker>.of(_markers),
          ),
        Positioned(
          bottom: 10.0,
          right: 10.0,
          child: Tooltip(
            message: 'Esconder/Exibir Mapa',
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showMap = !_showMap;
                });
              },
              child: Icon(
                _showMap ? Icons.map : Icons.map_outlined,
                color: Colors.white,
              ),
              backgroundColor: Colors.blue,
            ),
          ),
        ),
        if (_showMap)
          Positioned(
            top: 20.0,
            left: 0.0,
            right: 0.0,
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
            ),
          )
        else
          Positioned(
            top: 20.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                   Text(
                    "Corrida em andamento. Ative o mapa para ver o passageiro.",
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton.icon(
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
                ],
              ),
            ),
          ),
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
                      toastError(context, 'Houve um erro ao cancelar sua corrida! Tente novamente.');
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
