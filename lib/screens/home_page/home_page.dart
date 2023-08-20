import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grenierdufaso/functions/firebase_fcm.dart';
import 'package:grenierdufaso/screens/my_tontines/mes_tontines.dart';
import 'package:grenierdufaso/screens/notifs/notifs_screen.dart';
import 'package:grenierdufaso/screens/settings/settings_screen.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import '../../models/user.dart';
import '../../style/palette.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key});
  //final MyUser? user;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  bool isNotif1 = false;

  List<Widget> _buildNavScreens(BuildContext context) {
     MyUser user = MyUser(fullName: 'armel', email: 'email', isActive: 2);
    return [
      MesTontinesScreen(user: user),
      NotifsScreen(),
      SettingsScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(
          CupertinoIcons.money_dollar_circle,
          size: 22,
        ),
        title: "Mes tontines",
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        activeColorPrimary: Palette.appPrimaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Stack(
          children: [
            const Icon(
              CupertinoIcons.bell,
              size: 22,
            ),
            Positioned(
              right: 3,
              top: 5,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isNotif1 ? Colors.red : Colors.transparent,
                ),
              ),
            )
          ],
        ),
        title: "Notifications",
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        activeColorPrimary: Palette.appPrimaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          CupertinoIcons.settings,
          size: 22,
        ),
        title: "Paramètres",
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        activeColorPrimary: Palette.appPrimaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  void getBool() async {
    final isNotif = await FirebaseFCM.getIsNotif();
    if (isNotif != null) {
      setState(() {
        isNotif1 = isNotif;
      });
    }
  }

  @override
  void initState() {
    getBool();
    getUserData();
    super.initState();
  }
  MyUser? user;

void getUserData() {
  // Code pour récupérer les données de l'utilisateur à partir d'une source de données
  // Par exemple, une requête à une API ou une lecture depuis une base de données

  // Remplacez les valeurs statiques par les vraies valeurs de l'utilisateur
  user = MyUser(fullName: 'Nom de l\'utilisateur', email: 'email@example.com', isActive: 1);

  // Mettez à jour l'état pour refléter les nouvelles valeurs de l'utilisateur
  setState(() {});
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildNavScreens(context),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        decoration: NavBarDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: const ItemAnimationProperties(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style6,
      ),
    );
  }
}
