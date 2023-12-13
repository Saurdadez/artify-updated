import 'dart:io';

import 'package:art_app/components/text_fields.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic>? fetchedProfile;

  const EditProfile({super.key, required this.fetchedProfile});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  late String _profilePicture;

  @override
  void initState() {
    _profilePicture = widget.fetchedProfile?['profileurl'] ?? 'N/A';

    super.initState();
    if (widget.fetchedProfile?['streetAddress'] == 'N/A') {
      _streetAddressController.text = '';
    } else {
      _streetAddressController.text = widget.fetchedProfile?['streetAddress'];
    }
    if (widget.fetchedProfile?['zip'] == 'N/A') {
      _zipCodeController.text = '';
    } else {
      _zipCodeController.text = widget.fetchedProfile?['zip'];
    }
    if (widget.fetchedProfile?['cityAddress'] == 'N/A') {
      _cityController.text = '';
    } else {
      _cityController.text = widget.fetchedProfile?['cityAddress'];
    }
    _usernameController.text = widget.fetchedProfile?['username'];
    _firstNameController.text = widget.fetchedProfile?['firstName'];
    _lastNameController.text = widget.fetchedProfile?['lastName'];
  }

  var cropper = ImageCropper();
  String? _selectedCountryCode = 'PH (+63)';
  @override
  Widget build(BuildContext context) {
    BuildTextField textwidget = BuildTextField();
    _contactNumberController.text =
        widget.fetchedProfile?['contactNumber'] == 'N/A'
            ? ''
            : widget.fetchedProfile?['contactNumber'] ?? '';

    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    pickProfilePicture();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: _profilePicture.isNotEmpty &&
                                  !_profilePicture.contains('N/A')
                              ? _profilePicture ==
                                      (widget.fetchedProfile?['profileurl'])
                                  ? CircleAvatar(
                                      radius: 45,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        widget.fetchedProfile?['profileurl'],
                                      ),
                                    )
                                  : ClipOval(
                                      child: Image.file(
                                        File(_profilePicture),
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                      ),
                                    )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color.fromARGB(255, 83, 83, 83),
                                )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              onPressed: () {
                                pickProfilePicture();
                              },
                              icon: const Icon(Icons.camera_alt),
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    textwidget.fullTextField(_usernameController, 'Username'),
                    const SizedBox(height: 16.0),
                    textwidget.halfedTextField(
                      _firstNameController,
                      'First Name',
                      _lastNameController,
                      'Last Name',
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: _selectedCountryCode,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCountryCode = newValue;
                            });
                          },
                          itemHeight: 60,
                          items: [
                            'PH (+63)',
                            'US (+1)',
                          ].map<DropdownMenuItem<String>>((String? value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value ?? 'Select',
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TextFormField(
                              controller: _contactNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Contact Number',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    textwidget.fullTextField(
                      _streetAddressController,
                      'Street Address',
                    ),
                    const SizedBox(height: 16.0),
                    textwidget.halfedTextField(
                        _zipCodeController, 'Zip', _cityController, 'City'),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  saveProfileChanges();
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ));
  }

  void pickProfilePicture() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove current picture'),
              onTap: () {
                Navigator.pop(context);
                removeProfilePicture();
              },
            ),
          ],
        );
      },
    );
  }

  void pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      var cropped = await cropper.cropImage(
        sourcePath: pickedImage.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
      );

      if (cropped != null) {
        setState(() {
          _profilePicture = cropped.path;
        });
      } else {
        _profilePicture = 'N/A';
      }
    }
  }

  void removeProfilePicture() {
    setState(() {
      _profilePicture = 'N/A';
    });
  }

  void saveProfileChanges() async {
    await Modals.loaderPopup(context, 'Saving your changes...');
    await Future.delayed(const Duration(seconds: 2));

    String username = _usernameController.text;
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String contactNumber = _contactNumberController.text;
    String streetAddress = _streetAddressController.text;
    String zipCode = _zipCodeController.text;
    String city = _cityController.text;
    String countryCode =
        _selectedCountryCode!.split('(')[1].replaceAll(')', '').trim();
    if (_profilePicture.contains('N/A') &&
        _profilePicture != (widget.fetchedProfile?['profileurl'])) {
      await FirestoreService()
          .removeImageFromStorage(widget.fetchedProfile?['profileurl']);
    } else if (!_profilePicture.contains('N/A') &&
        _profilePicture != (widget.fetchedProfile?['profileurl'])) {
      debugPrint('This executed: ${widget.fetchedProfile?['profileurl']}');

      if (widget.fetchedProfile?['profileurl'] != 'N/A') {
        await FirestoreService()
            .removeImageFromStorage(widget.fetchedProfile?['profileurl']);
      }

      _profilePicture = await FirestoreService()
          .uploadImageToFirebase(_profilePicture, 'profileurls');
    }

    Map<String, dynamic> userUpdate = {
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'country': CountryList.getCountryNameFromCode(countryCode), // here
      'contactNumber': contactNumber,
      'cityAddress': city,
      'streetAddress': streetAddress,
      'zip': zipCode,
      'email': widget.fetchedProfile?['email'],
      'profileurl': _profilePicture,
    };
    await FirestoreService().updateProfile(userUpdate, widget.fetchedProfile);

    // ignore: use_build_context_synchronously
    PageTransitions().popToPageHome(context, 4);
  }
}
