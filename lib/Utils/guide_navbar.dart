import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourcompass/Settings/settings.dart';
import 'package:tourcompass/guide_home.dart';
import 'package:tourcompass/guide_order.dart';
import 'package:tourcompass/home.dart';
import 'package:tourcompass/order.dart';

class GuideNavigationMenu extends StatefulWidget {
  final String id;
  final String userType;
  final String token;

  const GuideNavigationMenu({
    required this.id,
    required this.token,
    required this.userType,
    Key? key,
  }) : super(key: key);

  @override
  State<GuideNavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<GuideNavigationMenu> {
  int index = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      GuideHomeContent(token: widget.token, id: widget.id),
      GuideOrderPage(id: widget.id),
      Setting(token: widget.token, id: widget.id, userType: widget.userType),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Color.fromARGB(255, 237, 113, 51),
        ),
        child: NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: index,
          backgroundColor: Colors.orange[900],
          onDestinationSelected: (index) => setState(() {
            this.index = index;
          }),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: ('Home')),
            NavigationDestination(icon: Icon(Icons.list), label: 'Orders'),
            NavigationDestination(
                icon: Icon(Icons.settings), label: ('Settings')),
          ],
        ),
      ),
      body: screens[index],
    );
  }
}
