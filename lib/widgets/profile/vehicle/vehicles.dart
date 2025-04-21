import 'package:app_motoblack_mototaxista/controllers/vehicleController.dart';
import 'package:app_motoblack_mototaxista/models/Vehicle.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/FloatingLoader.dart';
import 'package:app_motoblack_mototaxista/widgets/profile/vehicle/addVehicle.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/toast.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/errorMessage.dart';
import 'package:app_motoblack_mototaxista/widgets/profile/vehicle/editVehicle.dart';
import 'package:app_motoblack_mototaxista/widgets/profile/vehicle/vehicleCard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class Vehicles extends StatefulWidget {
  const Vehicles({super.key});


  @override
  State<Vehicles> createState() => _VehiclesState();

}

class _VehiclesState extends State<Vehicles> {


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

  void _changeVehicle(Vehicle? value) async {

    if(value?.inactiveReason != null){
      _editVehicle(value!);
      return;
    }

    if(value == null){
      return;
    }

    _isLoading.value = true;
    final ret = await controller.changeActiveVehicle(value.id);
    _isLoading.value = false;

    if (ret['error'] == false) {
        toastSuccess(context, 'Veículo ativado com sucesso.');
        loadVehicles(reset: true);
      } else {
        toastError(context, ret['status'] == 422 ? ret['error'] : 'Erro ao ativar veículo, tente novamente mais tarde.');
      }

  }

  void _addVehicle() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return AddVehicle(onAdded: () {
            Navigator.of(context).pop();
            loadVehicles(reset: true);
          });
        },
      );
  }


  void _editVehicle(Vehicle vehicle) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return EditVehicle(onUpdated: () {
            Navigator.of(context).pop();
            loadVehicles(reset: true);
          },vehicle: vehicle);
        },
      );

  }

  void _deleteVehicle(Vehicle vehicle) {
    controller.vehicles.remove(vehicle);
    setState(() {});
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
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  label: Text(
                    'Adicionar Veículo',
                    style: TextStyle(
                      fontSize: 18, color: Theme.of(context).colorScheme.secondary
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
                            VehicleCard(vehicle: controller.vehicles[index], onChanged: _changeVehicle, onDelete: _deleteVehicle)),
                   
                    FloatingLoader(active: _isLoading)

                  ],
                ),
              )
          ],
        )
      );
  }

}