import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourcompass/Settings/settings.dart';
import 'package:tourcompass/home.dart';
import 'package:tourcompass/order.dart';

// class CustomBottomNavigationBar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onItemTapped;

//   const CustomBottomNavigationBar({
//     required this.selectedIndex,
//     required this.onItemTapped,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home_filled),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.list),
//           label: 'Orders',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.settings),
//           label: 'Settings',
//         ),
//       ],
//       currentIndex: selectedIndex,
//       unselectedItemColor: Colors.white,
//       selectedItemColor: Colors.black,
//       onTap: onItemTapped,
//       backgroundColor: Colors.orange[900],
//     );
//   }
// }

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int index = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      HomeContent(),
      OrderPage(),
      Setting(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
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
