import 'package:art_app/components/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BuildTextField {
  Widget fullTextField(TextEditingController controller, String field) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              field,
              style: const TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 50,
              child: TextFormField(
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This is required field.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  alignLabelWithHint: false,
                  focusColor: Color.fromARGB(255, 253, 253, 253),
                  border: InputBorder.none,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: notifier.primary,
                      width: 1.0, // Border width when focused
                    ),
                    gapPadding: 10,
                  ),
                  fillColor: notifier.secondaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  static Widget expandedTextFieldContact(
      TextEditingController controller, String field) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              ' ',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 50,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This is required field.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  alignLabelWithHint: false,
                  focusColor: Color.fromARGB(255, 253, 253, 253),
                  border: InputBorder.none,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: notifier.primary,
                      width: 1.0, // Border width when focused
                    ),
                    gapPadding: 10,
                  ),
                  fillColor: notifier.secondaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget halfedTextField(
    TextEditingController controller1,
    String field1,
    TextEditingController controller2,
    String field2,
  ) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  field1,
                  style: const TextStyle(fontSize: 15),
                ),
                SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: controller1,
                    keyboardType: field1.contains('Zip')
                        ? TextInputType.phone
                        : TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This is required field.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      alignLabelWithHint: false,
                      focusColor: Color.fromARGB(255, 253, 253, 253),
                      border: InputBorder.none,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: notifier.primary,
                          width: 1.0, // Border width when focused
                        ),
                        gapPadding: 10,
                      ),
                      fillColor: notifier.secondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  field2,
                  style: const TextStyle(fontSize: 15),
                ),
                SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: controller2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This is required field.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      alignLabelWithHint: false,
                      focusColor: Color.fromARGB(255, 253, 253, 253),
                      border: InputBorder.none,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: notifier.primary,
                          width: 1.0, // Border width when focused
                        ),
                        gapPadding: 10,
                      ),
                      fillColor: notifier.secondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget halfedTextFormField(
    TextEditingController controller1,
    String field1,
    TextEditingController controller2,
    String field2,
  ) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: controller1,
                    keyboardType: field1.contains('Zip')
                        ? TextInputType.phone
                        : TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This is required field.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      alignLabelWithHint: false,
                      labelText: field1,
                      focusColor: Color.fromARGB(255, 253, 253, 253),
                      border: InputBorder.none,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: notifier.primary,
                          width: 1.0, // Border width when focused
                        ),
                        gapPadding: 10,
                      ),
                      fillColor: notifier.secondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: controller2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This is required field.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      alignLabelWithHint: false,
                      focusColor: Color.fromARGB(255, 253, 253, 253),
                      border: InputBorder.none,
                      labelText: field2,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: notifier.primary,
                          width: 1.0, // Border width when focused
                        ),
                        gapPadding: 10,
                      ),
                      fillColor: notifier.secondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget fullTextFormField(TextEditingController controller, String field) {
    return Consumer<ThemeNotifier>(
      builder: (context, notifier, child) {
        return TextFormField(
          controller: controller,
          maxLines: null,
          style: TextStyle(
            fontSize: 18,
            color: notifier.surfaceVariant,
          ),
          decoration: InputDecoration(
            labelText: field,
            alignLabelWithHint: false,
            focusColor: Color.fromARGB(255, 253, 253, 253),
            border: InputBorder.none,
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: notifier.primary,
                width: 1.0,
              ),
              gapPadding: 10,
            ),
            fillColor: notifier.secondaryContainer,
          ),
        );
      },
    );
  }

  static Widget fullTextFormFieldEmail(TextEditingController controller) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: notifier
                    .secondaryContainer, // Define the color for the border when enabled
              ),
            ),
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: notifier.primary,
                width: 1.0, // Border width when focused
              ),
              gapPadding: 10,
            ),
            fillColor: notifier.secondaryContainer,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          });
    });
  }

  Widget fullTextFormFieldNumber(
      TextEditingController controller, String field) {
    return Consumer<ThemeNotifier>(
      builder: (context, notifier, child) {
        return TextFormField(
          controller: controller,
          maxLines: null,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 18,
            color: notifier.surfaceVariant, // Use onPrimary color for text
          ),
          decoration: InputDecoration(
            labelText: field,
            alignLabelWithHint: false,
            focusColor: Color.fromARGB(255, 253, 253, 253),
            border: InputBorder.none,
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: notifier.primary,
                width: 1.0, // Border width when focused
              ),
              gapPadding: 10,
            ),
            fillColor: notifier.secondaryContainer,
          ),
        );
      },
    );
  }

  Widget fullTextFieldNumbers(TextEditingController controller, String field) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              field,
              style: const TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 50,
              child: TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This is required field.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  alignLabelWithHint: false,
                  focusColor: Color.fromARGB(255, 253, 253, 253),
                  border: InputBorder.none,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: notifier.primary,
                      width: 1.0, // Border width when focused
                    ),
                    gapPadding: 10,
                  ),
                  fillColor: notifier.secondaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget fullTextFieldPassword(TextEditingController controller, String field) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              field,
              style: const TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 50,
              child: TextFormField(
                obscureText: true,
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This is required field.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  alignLabelWithHint: false,
                  focusColor: Color.fromARGB(255, 253, 253, 253),
                  border: InputBorder.none,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: notifier.primary,
                      width: 1.0, // Border width when focused
                    ),
                    gapPadding: 10,
                  ),
                  fillColor: notifier.secondaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordFormField({super.key, required this.controller});

  @override
  PasswordFormFieldState createState() => PasswordFormFieldState();
}

class PasswordFormFieldState extends State<PasswordFormField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, notifier, child) {
        return TextFormField(
          controller: widget.controller,
          obscureText: !_showPassword,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              icon: _showPassword
                  ? const Icon(Icons.remove_red_eye_outlined)
                  : const Icon(Icons.remove_red_eye),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: notifier.onPrimary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: notifier.primary,
                width: 1.0,
              ),
              gapPadding: 10,
            ),
            filled: true,
            fillColor: notifier.secondaryContainer,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        );
      },
    );
  }
}
