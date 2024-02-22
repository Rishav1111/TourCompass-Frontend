// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tourcompass/Order.dart';
// import 'package:tourcompass/Settings.dart';
// import 'package:tourcompass/home.dart';

// class BottomNavBar extends StatelessWidget {
//   const BottomNavBar({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(NavigationController());

//     return Scaffold(
//       bottomNavigationBar: Obx(
//         () => NavigationBar(
//           key: UniqueKey(), // Key to force rebuild
//           height: 80,
//           elevation: 0,
//           selectedIndex: controller.selectedIndex.value,
//           onDestinationSelected: (index) =>
//               controller.selectedIndex.value = index,
//           destinations: const [
//             NavigationDestination(icon: Icon(Icons.home), label: "Home"),
//             NavigationDestination(icon: Icon(Icons.list), label: "Orders"),
//             NavigationDestination(icon: Icon(Icons.settings), label: "Setting"),
//           ],
//         ),
//       ),
//       body: Obx(() => controller.screens[controller.selectedIndex.value]),
//     );
//   }
// }

// class NavigationController extends GetxController {
//   final Rx<int> selectedIndex = 0.obs;

//   final screens = [
//     Container(color: Colors.green),
//     // Home(),
//     const OrderPage(),
//     const Setting(),
//   ];
// }
