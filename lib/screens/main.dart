import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/screens/activities.dart';
import 'package:app_motoblack_mototaxista/screens/home.dart';
import 'package:app_motoblack_mototaxista/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _pageIndex = 0;
  List<Widget> pages = [Home(), const Activities(), const Profile()];

  void _selectPage(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ActivityController(),
      child: Scaffold(
        body: IndexedStack(
          index: _pageIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          currentIndex: _pageIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Principal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Atividades',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.portrait),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
