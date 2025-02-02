import 'package:app_motoblack_mototaxista/controllers/vehicleController.dart';
import 'package:app_motoblack_mototaxista/widgets/FloatingLoader.dart';
import 'package:app_motoblack_mototaxista/widgets/addVehicle.dart';
import 'package:app_motoblack_mototaxista/widgets/errorMessage.dart';
import 'package:app_motoblack_mototaxista/widgets/vehicleCard.dart';
import 'package:flutter/material.dart';
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

  loadVehicles() async {
    _isLoading.value = true;
    await controller.getVehicles();
    _isLoading.value = false;
  }

  void _addVehicle() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return const AddVehicle();
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
            Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton.icon(
                    onPressed: _addVehicle,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: const Text(
                            'Adicionar Veículo',
                            style: TextStyle(
                                fontSize: 18, color: Colors.white),
                          )
                  ),
            ),
            const SizedBox(
              height: 12,
            ),
              Expanded(
                child:  message ?? Stack(
                  children: [
                    ...controller.vehicles.map((vehicle) => VehicleCard(vehicle: vehicle)).toList(),
                    FloatingLoader(active: _isLoading)
                  ],
                ),
              )
          ],
        )
      );
  }

}