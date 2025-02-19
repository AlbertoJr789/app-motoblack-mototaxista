
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/models/Passenger.dart';
import 'package:app_motoblack_mototaxista/models/Vehicle.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/infoBanner.dart';
import 'package:app_motoblack_mototaxista/widgets/trip/tripIcon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class ActivityDetails extends StatefulWidget {
  final Activity activity;

  const ActivityDetails({super.key, required this.activity});

  @override
  State<ActivityDetails> createState() => _ActivityDetailsState();
}

class _ActivityDetailsState extends State<ActivityDetails> {
  final List<Marker> _markers = [];

  final List<Polyline> _polylines = [];

  _initMarkers() async {

    _markers.add(Marker(
      markerId: MarkerId('origin'),
      position: LatLng(widget.activity.origin.latitude!, widget.activity.origin.longitude!),
      infoWindow: InfoWindow(title: 'Origem'),
      icon: await createFlagBitmapFromIcon(Icon(Icons.flag,color: Theme.of(context).colorScheme.secondary,)),
    ));

    _markers.add(Marker(
      markerId: MarkerId('destiny'),
      position: LatLng(widget.activity.destiny.latitude!, widget.activity.destiny.longitude!),
      infoWindow: InfoWindow(title: 'Destino'),
      icon: await createFlagBitmapFromIcon(Icon(Icons.flag_circle,color: Theme.of(context).colorScheme.surface,)),
    ));

    _polylines.add(Polyline(
      polylineId: PolylineId('route'),
      points: [
        LatLng(widget.activity.origin.latitude!, widget.activity.origin.longitude!),
        LatLng(widget.activity.destiny.latitude!, widget.activity.destiny.longitude!),
      ],
      color: Theme.of(context).colorScheme.secondary,
      width: 5,
    ));

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    String originTime = DateFormat('dd/MM/y HH:mm').format(widget.activity.createdAt!);
    String addrOrigin = '${widget.activity.origin.street} ${widget.activity.origin.number}';

    String destinyTime =
        DateFormat('dd/MM/y HH:mm').format(widget.activity.finishedAt!);
    String addrDestiny = '${widget.activity.origin.street} ${widget.activity.origin.number}';

    final dynamic showEval, showObs;

    if (widget.activity.canceled!) {
      showEval =
          InfoBanner(type: 'danger', msg: 'Esta atividade foi cancelada!');
      showObs = Text(
        'Justificativa de cancelamento: ${widget.activity.cancellingReason ?? '-'}',
        style: const TextStyle(fontSize: 18),
      );
    } else {
      showEval = _evaluation(widget.activity);
      showObs = Text(
        'Observações relatadas: ${widget.activity.obs ?? '-'}',
        style: const TextStyle(fontSize: 18),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Atividade'),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.activity.origin.latitude!, widget.activity.origin.longitude!),
                zoom: 12,
                ),
                markers: Set<Marker>.of(_markers),
                polylines: Set<Polyline>.of(_polylines),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.not_started,
                            color: Colors.black,
                            size: 40,
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              addrOrigin,
                              textAlign: TextAlign.start,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.timer_sharp,
                            color: Colors.black,
                            size: 40,
                          ),
                          Text(
                            originTime,
                            textAlign: TextAlign.start,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: SizedBox(
                          height: 30,
                          width: 3,
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.flag_circle,
                            color: Colors.black,
                            size: 40,
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              addrDestiny,
                              textAlign: TextAlign.start,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.timer_sharp,
                            color: Colors.black,
                            size: 40,
                          ),
                          Text(
                            destinyTime,
                            textAlign: TextAlign.start,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Color.fromARGB(232, 221, 214, 214),
                        thickness: 0.5,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _passengerDetails(widget.activity.passenger!, widget.activity.vehicle!),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: Color.fromARGB(232, 221, 214, 214),
                        thickness: 0.5,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      showEval,
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: Color.fromARGB(232, 221, 214, 214),
                        thickness: 0.5,
                      ),
                      showObs
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _evaluation(activity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Flexible(
          child: Text(
            'Sua avaliação',
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        RatingBar(
          ignoreGestures: true,
          initialRating: double.parse(activity.evaluation.toString()),
          itemCount: 5,
          ratingWidget: RatingWidget(
              full: const Icon(Icons.star, color: Colors.amber),
              half: const Icon(Icons.star_half, color: Colors.amber),
              empty: const Icon(
                Icons.star_outline_outlined,
                color: Color.fromARGB(255, 209, 203, 203),
              )),
          onRatingUpdate: (rate) {},
        )
        // EvaluationStar(activity.evaluation),
      ],
    );
  }

  Widget _passengerDetails(Passenger passenger,Vehicle vehicle) {
    int vehicleColor = int.parse(
      '0xFF${vehicle.color.toString().replaceFirst('#', '')}',
    );

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              const Text('Passageiro'),
              const SizedBox(
                height: 10,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person_off_outlined,color: Colors.black,),
                    imageUrl: passenger.avatar!),
              ),
            ],
          ),
          SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        Text('${passenger.name}'),
                        Row(
                          children: [
                            Text('Veículo que você utilizou'),
                            Text('Placa: ${vehicle.plate}, Cor: '),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Container(
                                color: Color(vehicleColor),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
