// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:io';

import 'package:art_app/components/text_fields.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/models/book_model.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BookCommissionPage extends StatefulWidget {
  const BookCommissionPage({super.key, required this.email});
  final String email;

  @override
  State<BookCommissionPage> createState() => _BookCommissionPageState();
}

class _BookCommissionPageState extends State<BookCommissionPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityRegionController = TextEditingController();
  final TextEditingController zipCodeCountryController =
      TextEditingController();
  var currentEmail = FirebaseAuth.instance.currentUser?.email;

  final TextEditingController descriptionReqController =
      TextEditingController();

  final List<XFile> _images = [];
  Map<String, dynamic>? fetchedProfile;

  @override
  void initState() {
    super.initState();
    fetchProfile(); // Start fetching the profile data
  }

  Future<void> fetchProfile() async {
    final user = await FirestoreService().getUserInfo(widget.email);
    setState(() {
      fetchedProfile = user;
    });
  }

  //String? filePath;
  void pickFile() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    setState(() {
      _images.addAll(pickedImages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Art Request Form'),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "So you want a \ncommission... ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "That's great! Thanks so much for considering me, let's check over the details!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.only(bottom: 22),
                    child: BuildTextField().fullTextFormField(
                      descriptionReqController,
                      'Tell us what you like us to make.',
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Art Reference',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: pickFile,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: notifier.secondaryContainer,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.file_upload,
                            color: Colors.white,
                          ),
                          Text(
                            'Browse Files\nChoose a File',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Files:',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (BuildContext context, int index) {
                            XFile image = _images[index];
                            return Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.file(
                                      File(image.path),
                                      width: 120, // Adjust width as needed
                                      height: 120, // Adjust height as needed
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      image.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      submitForm();
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void submitForm() async {
    await Modals.loaderPopup(context, 'Processing your request...');
    await Future.delayed(const Duration(seconds: 2));

    List<String> uploadedImageUrls = [];
    for (XFile image in _images) {
      String imageUrl = await FirestoreService()
          .uploadImageToFirebase(image.path, 'BookCommissionModel');
      uploadedImageUrls.add(imageUrl);
    }

    BookCommissionModel bookCommission = BookCommissionModel(
      firstName: fetchedProfile?['firstName'],
      lastName: fetchedProfile?['lastName'],
      email: widget.email,
      commissioner: currentEmail ?? '',
      contactNumber: fetchedProfile?['contactNumber'],
      address: fetchedProfile?['streetAddress'],
      city: fetchedProfile?['cityAddress'],
      zipCode: fetchedProfile?['zip'],
      descriptionRequest: descriptionReqController.text,
      artReference: uploadedImageUrls,
    );

    FirestoreService().addBookCommission(bookCommission).then((value) async {
      await Modals.showAlert(
          context, 'Request submitted', 'Thanks for choosing us!');
      PageTransitions().slideLeftToHome(context);
    });
  }

  Widget buildTextField(String labelText,
      {int? maxLines, String? hintText, bool smallField = false}) {
    TextEditingController controller;
    switch (labelText) {
      case 'First Name':
        controller = firstNameController;
        break;
      case 'Last Name':
        controller = lastNameController;
        break;
      case 'Email':
        controller = emailController;
        break;
      case 'Contact Number':
        controller = contactNumberController;
        break;
      case 'Street Address':
        controller = addressController;
        break;
      case 'City':
        controller = cityRegionController;
        break;
      case 'Zip Code':
        controller = zipCodeCountryController;
        break;
      case 'Description Of Request':
        controller = descriptionReqController;
        break;
      default:
        controller = TextEditingController();
    }

    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        contentPadding: smallField
            ? EdgeInsets.symmetric(vertical: 10, horizontal: 8)
            : EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}
