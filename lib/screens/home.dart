
import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/util/util.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/errorMessage.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/news_carousel.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/toast.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/weatherDisplay.dart';
import 'package:app_motoblack_mototaxista/widgets/trip/toggleOnline.dart';
import 'package:app_motoblack_mototaxista/widgets/trip/trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  late ActivityController _tripController;
  bool _error = false;
  bool _isCheckingActivity = false;

  @override
  void initState() {
    super.initState();
    _tripController = Provider.of<ActivityController>(context, listen: false);
  }


  _checkActivity() async {
    try{
      await _tripController.checkCurrentActivity();
      _error = false;

      if(_tripController.currentActivity != null){

        if(_tripController.currentActivity!.canceled == true){
           if(_tripController.currentActivity!.whoCancelled == WhoCancelled.passenger){
            _tripController.checkCancelled = 0;
            String reason = _tripController.currentActivity!.cancellingReason ?? 'Não informado';
            _tripController.removeCurrentActivity();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showAlert(context, 
                  'A corrida foi cancelada pelo passageiro', 
                  sol: 'Motivo: $reason');
            });
          }
        }else{
          if(_tripController.currentActivity!.finishedAt != null){
            _ratePendentTripDialog();
            return;
          }else{
            _tripController.toggleTrip(enabled: true);
          }
        }
      }else{
        _tripController.toggleTrip(enabled: true);
      }
      _isCheckingActivity = false;
      _error = false;
    }catch(e){
      _error = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _tripController = context.watch<ActivityController>();
    
    if(!_tripController.enableTrip && !_isCheckingActivity){
      _isCheckingActivity = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkActivity();
      });
    }

    Widget widget;
    if(_error){
        widget = ErrorMessage(msg: 'Houve um erro ao tentar verificar seus status', tryAgainAction: _checkActivity);
    }else{
      if(_tripController.currentActivity != null && _tripController.enableTrip){
        widget = const Trip();
      }else{
        widget = Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Text("Iniciar atividades",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .inversePrimary)),
          const SizedBox(
            height: 12,
          ),
          if(_tripController.enableTrip)
            const ToggleOnline(),

          const WeatherDisplay(),
          const SizedBox(height: 20),
          const Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: NewsCarousel(),
              ),
            ),
          ),

        ],
      )); 
      } 
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget
          ),
    );
  }

  final _formDialogKey = GlobalKey<FormState>();
  bool _isDialogLoading = false;
  double _evaluation = 0;
  TextEditingController _obs = TextEditingController();

  _ratePendentTripDialog() {
    print('avaliar corrida');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Form(
            key: _formDialogKey,
            child: Column(
              children: [
                Text(
                  'Ooops, parece que o passageiro finalizou a corrida e você ainda não o avaliou !',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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
                  final ret = await _tripController.finishActivity(
                    trip: _tripController.currentActivity!,
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
                    _tripController.removeCurrentActivity();
                    _isCheckingActivity = false;
                    _evaluation = 0;
                    _obs.clear();
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
                  : Text('Concluir'),
            ),
          ],
        );
      }),
    );
  }

}
