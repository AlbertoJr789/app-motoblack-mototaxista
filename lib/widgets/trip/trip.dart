import 'dart:async';

import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/controllers/geoCoderController.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/toast.dart';
import 'package:app_motoblack_mototaxista/widgets/trip/tripIcon.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _allowConclusion = false;
  double _acceptableRadius = 30;


  @override
  initState() {
    super.initState();
    _controller = Provider.of<ActivityController>(context, listen: false);
    _listenTrip();
  }

  @override
  Widget build(BuildContext context) {
    if(_passengerIcon == null){
      _createMarkerIcon();
    }

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
                circles: {
                  Circle(
                    circleId: const CircleId('destination-area'),
                    onTap: (){
                      toastInfo(context, 'Deixe o passageiro neste raio para conseguir concluir a corrida, entenderemos que chegou próximo ao seu destino');
                    },
                    center: LatLng(
                        _controller.currentActivity!.destiny.latitude!,
                        _controller.currentActivity!.destiny.longitude!),
                    radius: _acceptableRadius,
                    strokeWidth: 2,
                    strokeColor:
                        _allowConclusion ? Colors.green : Colors.red,
                    fillColor: _allowConclusion
                        ? Colors.greenAccent.withOpacity(0.2)
                        : Colors.redAccent.withOpacity(0.2),

                  ),
                },
          ),
           Positioned(
          bottom: 150.0,
          right: 10.0,
          child: Tooltip(
            message: 'Ver rota até o passageiro',
            child: FloatingActionButton(
              onPressed: () async {   
                final myCoords = await FirebaseDatabase.instance.ref('availableAgents').child(await Agent.getUuid()).get();
                
                final currentLocationAddress = await GeoCoderController().inverseGeocode(
                  double.parse((myCoords.value as Map)['latitude'].toString()),
                  double.parse((myCoords.value as Map)['longitude'].toString())
                );
                
                final passengerCoords = await FirebaseDatabase.instance.ref('trips').child(_controller.currentActivity!.uuid!).child('passenger').get();
                final passengerCurrentLocationAddress = await GeoCoderController().inverseGeocode(
                  double.parse((passengerCoords.value as Map)['latitude'].toString()),
                  double.parse((passengerCoords.value as Map)['longitude'].toString())
                );
                
                launchUrl(Uri.parse('https://www.google.com/maps/dir/${currentLocationAddress.googleMapsFormattedAddress}/${passengerCurrentLocationAddress.googleMapsFormattedAddress}'));
              },
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
              backgroundColor: Colors.blue,
            ),
          ),
        ),
        Positioned(
          bottom: 80.0,
          right: 10.0,
          child: Tooltip(
            message: 'Ver rota da corrida',
            child: FloatingActionButton(
              onPressed: () {
                launchUrl(Uri.parse('https://www.google.com/maps/dir/${_controller.currentActivity!.origin.googleMapsFormattedAddress}/${_controller.currentActivity!.destiny.googleMapsFormattedAddress}'));
              },
              child: Icon(
                Icons.route,
                color: Colors.white,
              ),
              backgroundColor: Colors.blue,
            ),
          ),
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
                icon: Icon(
                  _allowConclusion ? Icons.check : Icons.close,
                  color: Colors.white,
                ),
                label: Text(
                  _allowConclusion ? "Concluir" : "Cancelar",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      _allowConclusion ? Colors.green : Colors.red), // Set the background color of the icon
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
                    icon: Icon(
                      _allowConclusion ? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                    label: Text(
                      _allowConclusion ? "Concluir" : "Cancelar",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          _allowConclusion ? Colors.green : Colors.red), // Set the background color of the icon
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }


  
  void _createMarkerIcon() async {
    try {
      
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

    //init passenger location
    FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .child('passenger').get().then((value) async {
          if(value.exists){
            final String url = '${ApiClient.instance.baseUrl}/api/marker/${_controller.currentActivity!.passenger!.userId}';
            final data = value.value as Map;
            _markers.add(Marker(
              markerId: const MarkerId('passenger'),
              position: LatLng(
                  data['latitude'],
                  data['longitude']),
              icon: _passengerIcon ??= await getMarkerImageFromUrl(url,targetWidth: 120) ,
              infoWindow: const InfoWindow(
                title: 'Seu Passageiro',
              ),
            ));
            _checkRadius();
          }
        });

    _stream = FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .onValue
        .listen((querySnapshot) {
      if (querySnapshot.snapshot.exists) {
        final data = querySnapshot.snapshot.value as Map;  
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
        _checkRadius();
      }else{
        if(_isDialogLoading == false){
          _stream.cancel();
          _controller.checkCancelled = _controller.currentActivity!.id!;
          _controller.toggleTrip(enabled: false,notify: true);
        }
      }
    });
  }

   _checkRadius() {
    final destination = _controller.currentActivity!.destiny;
    final passengerPosition = _markers
        .firstWhere((marker) => marker.markerId.value == 'passenger')
        .position;

    final passengerDistance = Geolocator.distanceBetween(
      passengerPosition.latitude,
      passengerPosition.longitude,
      destination.latitude!,
      destination.longitude!,
    );

    if (mounted) {
      setState(() {
        _allowConclusion = passengerDistance <= _acceptableRadius;
      });
    }
  
  }


   void _endTripDialog() {

    if (_allowConclusion) {
      _finishTripDialog();
      return;
    }

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
  final _formDialogKey = GlobalKey<FormState>();
  bool _isDialogLoading = false;

  void _cancelTripDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Form(
              key: _formDialogKey,
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
                  if (_formDialogKey.currentState!.validate()) {
                    setState(() {
                      _isDialogLoading = true;
                    });
                    final ret = await _controller.cancelActivity(
                      trip: _controller.currentActivity!,
                      reason: _cancellingReason.text,
                    );
                    setState(() {
                      _isDialogLoading = false;
                    });
                    
                    if (!ret) {
                      toastError(context, 'Houve um erro ao cancelar sua corrida! Tente novamente.');
                    }else{
                      Navigator.pop(ctx);
                      toastSuccess(context, 'Corrida cancelada com sucesso!');
                    }

                  }
                },
                child: _isDialogLoading ? Padding(
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

  double _evaluation = 0;
  TextEditingController _obs = TextEditingController();

  _finishTripDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Form(
            key: _formDialogKey,
            child: Column(
              children: [
                Text(
                  'Sua opinião é muito importante para nós! Por gentileza, avalie o passageiro:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                FormField(
                  builder: (field) => RatingBar(
                    initialRating: _evaluation,
                    itemCount: 5,
                    allowHalfRating: true,
                    glowColor: Colors.amber,
                    glowRadius: 1,
                    ratingWidget: RatingWidget(
                        full: const Icon(Icons.star, color: Colors.amber),
                        half: const Icon(Icons.star_half, color: Colors.amber),
                        empty: const Icon(
                          Icons.star_outline_outlined,
                          color: Color.fromARGB(255, 209, 203, 203),
                        )),
                    onRatingUpdate: (rate) {
                      _evaluation = rate;
                    },
                  ),
                  validator: (value) {
                    if (_evaluation == 0) {
                      toastError(context, 'Por gentileza, avalie o passageiro');
                      return 'Por gentileza, avalie o passageiro';
                    }
                    return null;
                  },
                ),
                Text(
                  'Observação: ',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.start,
                ),
                TextFormField(
                  controller: _obs,
                  maxLines: 2,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText:
                        'Deixe uma observação/comentário sobre a corrida caso necessário',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                )
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formDialogKey.currentState!.validate()) {
                  setState(() {
                    _isDialogLoading = true;
                  });
                  final ret = await _controller.finishActivity(
                    trip: _controller.currentActivity!,
                    evaluation: _evaluation,
                    evaluationComment: _obs.text,
                  );
                  setState(() {
                    _isDialogLoading = false;
                  });
                  if (!ret) {
                    toastError(context,
                        'Houve um erro ao concluir sua corrida! Tente novamente.');
                  } else {
                    Navigator.pop(ctx);
                    toastSuccess(context,
                        'Corrida concluída com sucesso! Agradecemos pelo serviço prestado!');
                  }
                }
              },
              child: _isDialogLoading
                  ? Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : const Text('Concluir'),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    try{
      _stream.cancel();
    }catch(e){}
    super.dispose();
  }


}
