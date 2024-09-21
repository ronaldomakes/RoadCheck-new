import 'package:flutter/material.dart';


import '../../back/models/menu.dart';
import '../../back/utils/rive_utils.dart';
import '../../core/constants/constants.dart';
import '../home_screen/home_screen.dart';
import '../map_screen/map_screen.dart';
import '../profile_screen/profile_screen.dart';
import 'components/btm_nav_item.dart';

class BottomNavigationScreen extends StatefulWidget {
  int? tabIndex;
  static String routeName = RouteNames.bottomNavBarScreen;
  BottomNavigationScreen({Key? key, this.tabIndex}) : super(key: key);

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> with SingleTickerProviderStateMixin {
  int selectedTabIndex = 0;
  Menu selectedBottonNav = bottomNavItems.first;

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
      setState(() {});
    });

    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    selectedTabIndex = widget.tabIndex ?? 0;
  }

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const GoogleMapFlutter(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  void updateSelectedBtmNav(Menu menu) {
    if (selectedBottonNav != menu) {
      setState(() {
        selectedBottonNav = menu;
        _onItemTapped(bottomNavItems.indexOf(menu)); // Update selected tab index
      });
    }
  }
  List<String> titlesNav = [
    "Главная",
    'Карта',
    "Профиль"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: selectedTabIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, 100 * animation.value),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            margin: const EdgeInsets.only(left: 24, right: 24, bottom: 15),
            decoration: BoxDecoration(
              color: Color(0xFF27A105).withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF27A105).withOpacity(0.3),
                  offset: const Offset(0, 20),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(
                  bottomNavItems.length,
                      (index) {
                    Menu navBar = bottomNavItems[index];
                    return BtmNavItem(
                      title: titlesNav[index],
                      navBar: navBar,
                      press: () {
                        RiveUtils.chnageSMIBoolState(navBar.rive.status!);
                        updateSelectedBtmNav(navBar);
                      },
                      riveOnInit: (artboard) {
                        navBar.rive.status = RiveUtils.getRiveInput(
                          artboard,
                          stateMachineName: navBar.rive.stateMachineName,
                        );
                      },
                      selectedNav: selectedBottonNav,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}