import 'package:art_app/components/page_notifier.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/pages/useradd_page.dart';
import 'package:art_app/pages/home_page.dart';
import 'package:art_app/pages/discover_page.dart';
import 'package:art_app/pages/profile_page.dart';
import 'package:art_app/pages/search_page.dart';
import 'package:art_app/services/auth_service.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  BottomNavigationState createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation> {
  late PageChangeNotifier pageChangeNotifier;

  void updateUI() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    pageChangeNotifier.removeListener(() {});
  }

  int _currentIndex = 0;
  bool activeHome = true;
  int taps = 1;
  void _onItemTapped(int index) async {
    if (mounted) {
      pageChangeNotifier.updateIndex(index);
      setState(() {
        _currentIndex = pageChangeNotifier.currentIndex;
      });
    }
  }

  void updateOnlineStatus(bool status) {
    if (mounted) {
      setState(() {});
    }
  }

  List<Widget> destinations = [
    const Home(),
    const SearchPage(),
    const AddPost(),
    const DiscoverPage(),
    const ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    pageChangeNotifier =
        Provider.of<PageChangeNotifier>(context, listen: false);
    _currentIndex = pageChangeNotifier.currentIndex;
    pageChangeNotifier.addListener(updateUI);

    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: destinations,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: notifier.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      child: _buildNavItem(
                          Icons.home_outlined, Icons.home, 'Home', 0),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      child: _buildNavItem(Icons.search_rounded,
                          Icons.search_rounded, 'Search', 1),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      child: _addNavItem(),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      child: _buildNavItem(Icons.window_outlined,
                          Icons.window_rounded, 'Category', 3),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      child: FutureBuilder<bool>(
                        future: AuthService().isUserLoggedIn(),
                        builder: (context, loggedInSnapshot) {
                          if (loggedInSnapshot.hasData &&
                              loggedInSnapshot.data == true) {
                            return FutureBuilder<String?>(
                              future: AuthService().getCurrentUserEmail(),
                              builder: (context, emailSnapshot) {
                                if (emailSnapshot.hasData &&
                                    emailSnapshot.data != null) {
                                  return StreamBuilder<String>(
                                    stream: FirestoreService()
                                        .getUserProfileUrl(emailSnapshot.data!),
                                    builder: (context, profileSnapshot) {
                                      if (profileSnapshot.hasData) {
                                        String profileUrl =
                                            profileSnapshot.data ?? '';

                                        if (profileUrl == 'N/A') {
                                          return _buildNavItem(
                                            Icons.person_2_outlined,
                                            Icons.person_2_rounded,
                                            'Profile',
                                            4,
                                          );
                                        }
                                        return buildProfileItem(profileUrl);
                                      }
                                      return _buildNavItem(
                                        Icons.person_2_outlined,
                                        Icons.person_2_rounded,
                                        'Profile',
                                        4,
                                      );
                                    },
                                  );
                                }
                                return _buildNavItem(
                                  Icons.person_2_outlined,
                                  Icons.person_2_rounded,
                                  'Profile',
                                  4,
                                );
                              },
                            );
                          }
                          return _buildNavItem(
                            Icons.person_2_outlined,
                            Icons.person_2_rounded,
                            'Profile',
                            4,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget buildProfileItem(String url) {
    return GestureDetector(
        onTap: () {
          _onItemTapped(4);
          setState(() {
            activeHome = false;
            taps = 0;
          });
        },
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(url),
              ),
            ),
          ),
        ));
  }

  Widget _addNavItem() {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return GestureDetector(
        onTap: () => {},
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [notifier.primary, notifier.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add),
              color: Colors.white,
              onPressed: () {
                Modals.expandedModal(context, const AddPost(), notifier);
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(
      IconData icon, IconData activeIcon, String label, int index) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
        if (_currentIndex == 0) {
          activeHome = true;
          taps++;
          if (taps == 2 && activeHome) {
            pageChangeNotifier.updateRefreshHome(true);

            taps = 1;
            activeHome = true;

            pageChangeNotifier.updateRefreshHome(false);
          }
        } else {
          setState(() {
            activeHome = false;
            taps = 0;
          });
        }
      },
      child: Center(
        child: Icon(
          size: label == 'Category' ? 25 : 26,
          isActive ? activeIcon : icon,
          color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
      ),
    );
  }
}
