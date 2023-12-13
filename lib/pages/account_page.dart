// ignore_for_file: use_build_context_synchronously

import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/pages/about_page.dart';
import 'package:art_app/pages/userfav.dart';
import 'package:art_app/pages/userliked_page.dart';
import 'package:art_app/services/auth_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Account',
            style: TextStyle(fontSize: 16),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.navigate_before_rounded,
              size: 25,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text('View Likes', style: TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.favorite_rounded),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => const LikedPage()));
              },
            ),
            ListTile(
              title: const Text('Favorites'),
              trailing: const Icon(Icons.star_rounded),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => const FavPage()));
              },
            ),
            ListTile(
              title: const Text('Follows'),
              trailing: const Icon(Icons.people_rounded),
              onTap: () {},
            ),
            ListTile(
              title: const Text('About'),
              trailing: const Icon(Icons.info_rounded),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => const AboutPage()));
              },
            ),
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.logout_rounded),
              onTap: () async {
                Modals.loaderPopup(context, 'Signing out...');

                AuthService().logout();
                await Future.delayed(const Duration(seconds: 2));

                PageTransitions().slideLeftToHome(context);
              },
            ),
          ],
        ),
      );
    });
  }
}
