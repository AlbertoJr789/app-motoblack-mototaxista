import 'package:app_motoblack_mototaxista/widgets/help.dart';
import 'package:app_motoblack_mototaxista/widgets/paymentDetails.dart';
import 'package:app_motoblack_mototaxista/widgets/profileDetails.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dados Pessoais'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Info. Conta',
              ),
              // Tab(
              //   text: 'Pagamentos',
              // ),
              // Tab(
              //   text: 'Ajuda',
              // ),
            ],
          ),
        ),
        body: const TabBarView(children: [
             ProfileDetails(),
            //  PaymentDetails(),
            //  HelpDetails()
        ]),
      ),
    );
  }
}
