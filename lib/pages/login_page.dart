// ignore_for_file: use_build_context_synchronously

import 'package:art_app/components/text_fields.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/components/tiles_widget.dart';
import 'package:art_app/pages/register_page.dart';
import 'package:art_app/services/auth_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        backgroundColor: notifier.primaryContainer,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 1,
          surfaceTintColor: notifier.primaryContainer,
          leading: IconButton(
            icon: const Icon(
              Icons.navigate_before_rounded,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: notifier.primaryContainer,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Sign in with your account',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
                        const Text(
                          'Password',
                          style: TextStyle(fontSize: 15),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        PasswordFormField(controller: _passwordController),
                        const SizedBox(
                          height: 50,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: MaterialButton(
                            onPressed: () async {
                              final form = _formKey.currentState;
                              if (form != null && form.validate()) {
                                Modals.loadingModal(context);
                                try {
                                  await AuthService().signUserIn(
                                      _emailController.text,
                                      _passwordController.text);
                                  PageTransitions().slideLeftToHome(context);
                                } on FirebaseAuthException catch (e) {
                                  Navigator.pop(context);
                                  if (e.code == 'invalid-credential') {
                                    Modals.showAlert(context,
                                        'Incorrect email or password', 'Oops!');
                                  } else {
                                    Modals.showAlert(
                                        context,
                                        'Something went wrong. Please try again.',
                                        'Error');
                                  }
                                }
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
                  const Text('Or login with'),
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
                          const Text('Dont have an account?'),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage()));
                            },
                            child: const Text(
                              '  Create an account',
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
