// ignore_for_file: use_build_context_synchronously

import 'package:art_app/components/text_fields.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/components/tiles_widget.dart';
import 'package:art_app/services/auth_service.dart';
import 'package:art_app/pages/register_info_page.dart';
import 'package:art_app/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final auth = AuthService();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        backgroundColor: notifier.onPrimary,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 1,
          surfaceTintColor: notifier.onPrimary,
          leading: IconButton(
            icon: const Icon(
              Icons.navigate_before_rounded,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: notifier.onPrimary,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'artify.',
                    style: TextStyle(
                        color: notifier.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 50),
                  ),
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Email address',
                          style: TextStyle(fontSize: 15),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        BuildTextField.fullTextFormFieldEmail(_emailController),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: MaterialButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterInfoPage(
                                        email: _emailController.text),
                                  ),
                                );
                              }
                            },
                            height: 45,
                            color: notifier.primary,
                            child: const Text(
                              'CONTINUE',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Or join with'),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TileWidget(
                            imagePath: 'lib/images/icons8-google-30.png',
                            onTap: () async {
                              Modals.loadingModal(context);
                              try {
                                await AuthService()
                                    .signInWithGoogle()
                                    .then((value) {
                                  if (value) {
                                    PageTransitions().slideLeftToHome(context);
                                  } else {
                                    Navigator.pop(context);
                                  }
                                });
                              } catch (e) {
                                Modals.showAlert(context, e.toString(),
                                    'Oops! Something went wrong');
                              }
                            }),
                        const SizedBox(
                          width: 35,
                        ),
                        TileWidget(
                            imagePath: 'lib/images/icons8-facebook-48.png',
                            onTap: () => ()),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: 100,
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text(
                              '  Sign in',
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        ],
                      )))
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
