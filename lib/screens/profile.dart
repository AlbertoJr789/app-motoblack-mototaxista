// import 'package:app_motoblack_cliente/widgets/help.dart';
// import 'package:app_motoblack_cliente/widgets/paymentDetails.dart';
import 'package:app_motoblack_mototaxista/controllers/loginController.dart';
import 'package:app_motoblack_mototaxista/controllers/vehicleController.dart';
import 'package:app_motoblack_mototaxista/widgets/profile/profileDetails.dart';
import 'package:app_motoblack_mototaxista/widgets/profile/vehicle/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dados Pessoais'),
          actions: [
            Tooltip(message: 'Sair da conta',child: IconButton(onPressed: (){
                 showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sair da conta'),
                      content: const Text("Quer realmente sair da sua conta?"),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                          child: const Text('Não'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            LoginController.logoff();
                          },
                          child: const Text('Sim'),
                        )
                      ],
                    ),
                  );
            }, icon: Icon(Icons.logout_outlined,size: 36,)))
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Info. Conta',
              ),
              Tab(
                text: 'Meus Veículos',
              ),
              // Tab(
              //   text: 'Ajuda',
              // ),
            ],
          ),
        ),
        body: TabBarView(children: [
          const ProfileDetails(),
          ChangeNotifierProvider(create: (context) => VehicleController(), child: const Vehicles()),
          //  PaymentDetails(),
          //  HelpDetails()
        ]),
      ),
    );
  }
}
