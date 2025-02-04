import 'package:app_motoblack_mototaxista/controllers/vehicleController.dart';
import 'package:app_motoblack_mototaxista/widgets/FloatingLoader.dart';
import 'package:app_motoblack_mototaxista/widgets/addVehicle.dart';
import 'package:app_motoblack_mototaxista/widgets/assets.dart';
import 'package:app_motoblack_mototaxista/widgets/errorMessage.dart';
import 'package:app_motoblack_mototaxista/widgets/vehicleCard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class VehiclesDetails extends StatefulWidget {
  const VehiclesDetails({super.key});

  @override
  State<VehiclesDetails> createState() => _VehiclesDetailsState();
}

class _VehiclesDetailsState extends State<VehiclesDetails> {

  late VehicleController controller;
  final ScrollController _scrollController = ScrollController();
  final _isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          controller.hasMore) {
        loadVehicles();
      }
    });
    controller = Provider.of<VehicleController>(context, listen: false);
    loadVehicles();

  }

  loadVehicles({bool reset=false}) async {
    _isLoading.value = true;
    await controller.getVehicles(reset);
    _isLoading.value = false;
  }

  void _changeVehicle(int? value) async {
    _isLoading.value = true;
    final ret = await controller.changeActiveVehicle(value!);
    _isLoading.value = false;

    if (ret['error'] == false) {
        FToast().init(context).showToast(
            child: MyToast(
              msg: const Text(
                'Veículo ativado com sucesso.',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              color: Colors.greenAccent,
            ),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 4));

            loadVehicles(reset: true);
      } else {
        FToast().init(context).showToast(
            child: MyToast(
              msg: Text(
                ret['status'] == 422
                    ? ret['error']
                    : 'Erro ao ativar veículo, tente novamente mais tarde.',
                style: const TextStyle(
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
      }

  }

  void _addVehicle() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return AddVehicle(onAdded: () => loadVehicles(reset: true));
        },
      );
  }


  Widget build(BuildContext context) {

    controller = context.watch<VehicleController>();
    dynamic message;

    if(controller.error.isNotEmpty){
        message = ErrorMessage(msg: 'Houve um erro ao tentar obter seus veículos', tryAgainAction: controller.getVehicles);
    }else{
      if(controller.vehicles.isEmpty){
        message = ErrorMessage(msg: 'Você ainda não possui nenhum veículo.\nFaça seu primeiro cadastro!',icon: const Icon(Icons.notes,size: 128,color: Colors.white60,),);
      }else{
        message = null;
      }
    }
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        child: Column(
          children: [
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _addVehicle,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Adicionar Veículo',
                    style: TextStyle(
                      fontSize: 18, color: Colors.white
                    ),
                  )
                ),
                IconButton(
                  onPressed: () => loadVehicles(reset: true),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
              Expanded(
                child:  message ?? Stack(
                  children: [
                     ListView.builder(
                        controller: _scrollController,
                        itemCount: controller.vehicles.length,
                        itemBuilder: (ctx, index) =>
                            VehicleCard(vehicle: controller.vehicles[index], onChanged: _changeVehicle)),
                   
                    FloatingLoader(active: _isLoading)

                  ],
                ),
              )
          ],
        )
      );
  }

}