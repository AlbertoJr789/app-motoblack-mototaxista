import 'package:app_motoblack_mototaxista/controllers/vehicleController.dart';
import 'package:app_motoblack_mototaxista/models/Vehicle.dart';
import 'package:app_motoblack_mototaxista/widgets/activity/activityDetails.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/textBadge.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final Function(Vehicle?) onChanged;
  final Function(Vehicle) onDelete;
  VehicleCard({super.key, required this.vehicle, required this.onChanged, required this.onDelete});
  final VehicleController controller = VehicleController();

  bool _isDeleting = false;
  Future<bool> _deleteVehicle(BuildContext context) async {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Excluir veículo'),
            content: const Text("Quer realmente excluir este veículo?"),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Não'),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isDeleting = true;
                  });
          
                  final ret = await controller.deleteVehicle(vehicle.id);
          
                  if (ret['error'] == false) {
                    if(context.mounted){
                      toastSuccess(context, 'Veículo excluído com sucesso.');
                      Navigator.of(ctx).pop(true);
                    }
                  } else {
                    if(context.mounted){
                      toastError(context, ret['status'] == 422
                                ? ret['error']
                                : 'Erro ao excluir veículo, tente novamente mais tarde.');                      
                      Navigator.of(ctx).pop(false);
                    }
                  }
                },
                child: _isDeleting ? const CircularProgressIndicator() : const Text('Sim'),
              )
            ],
          ),
        ),
      );
      return result ?? false;
  }

  Widget build(BuildContext context) {

    return Dismissible(
      key: Key(vehicle.id.toString()),
      onDismissed: (direction) {
        onDelete(vehicle);
      },
      confirmDismiss: (direction) {
        return _deleteVehicle(context);
      },
      background: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Icon(Icons.delete, color: Colors.white,),

      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Icon(Icons.delete, color: Colors.white,),
      ),
      child: Card(
        shadowColor: const Color.fromARGB(255, 197, 179, 88),
        color: vehicle.inactiveReason == null ? const Color.fromARGB(243, 221, 221, 219) : const Color.fromARGB(125, 255, 252, 252),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
            RadioListTile<Vehicle>(
                title: TextBadge(msg: Text('${vehicle.typeName} ${vehicle.brand} - ${vehicle.model}',style: Theme.of(context).textTheme.bodyLarge,),color: vehicle.inactiveReason == null ? null : const Color.fromARGB(96, 197, 179, 88),),
                subtitle: vehicle.inactiveReason != null ? Text('${vehicle.plate} - ${vehicle.inactiveReason!}',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.errorContainer),)
                    : Row(
                  children: [
                      Text(vehicle.plate,style: Theme.of(context).textTheme.bodyMedium,),
                      Text(' - Ativo',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.green),),
                  ],
                ), 
                value: vehicle,
                groupValue: vehicle.currentActiveVehicle ? vehicle : null,
                onChanged: onChanged,
              ),
        ),
      ),
    );

  }
}
