import 'package:art_app/pages/login_page.dart';
import 'package:flutter/material.dart';

class ProfileUnsigned extends StatefulWidget {
  const ProfileUnsigned({super.key});

  @override
  State<ProfileUnsigned> createState() => _ProfileUnsignedState();
}

class _ProfileUnsignedState extends State<ProfileUnsigned> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          elevation: 0.0,
          title: const Text(
            'Collection',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('You are not signed in'),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
