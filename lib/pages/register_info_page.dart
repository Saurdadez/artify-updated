import 'dart:io';

import 'package:art_app/components/text_fields.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/services/auth_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:art_app/models/user_model.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RegisterInfoPage extends StatefulWidget {
  const RegisterInfoPage({super.key, required this.email});

  final String email;
  @override
  State<RegisterInfoPage> createState() => _RegisterInfoPageState();
}

class _RegisterInfoPageState extends State<RegisterInfoPage> {
  bool dataFetched = false;
  late List<String> interests = [];
  Map<String, String>? _selectedCountry;
  var country = CountryList();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String _imageFilePath = '';
  bool isLoading = false;
  List<String> selectedInterests = [];
  final FirestoreService fireservice = FirestoreService();
  final auth = AuthService();
  final GlobalKey<FormState> _firstPageKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _secondPageKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _contactController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _buildTextField = BuildTextField();
  final _passwordController = TextEditingController();
  final _confirmpassController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetController.dispose();
    _contactController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _passwordController.dispose();
    _confirmpassController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    country = CountryList();
    fetchCategories();
    List<Map<String, String>> countryList = country.getList();
    _selectedCountry = countryList.isNotEmpty ? countryList[0] : null;
  }

  Future<void> fetchCategories() async {
    interests = await fireservice.getCategoriesAsList();
    setState(() {});
  }

  bool isSelected(String interest) {
    return selectedInterests.contains(interest);
  }

  void nextPage() {
    _pageController.nextPage(duration: kTabScrollDuration, curve: Curves.ease);
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _imageFilePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: notifier.onPrimary,
        appBar: AppBar(
          elevation: 0,
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
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildFirstPage(notifier),
            _buildSecondPage(notifier),
            _buildThirdPage(notifier),
          ],
        ),
      );
    });
  }

  bool _isUsernameAvailable = false;
  Color _usernameBorderColor = Colors.black;
  String _usernameErrorText = '';

  Widget _buildSecondPage(ThemeNotifier notifier) {
    return Form(
      key: _secondPageKey,
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                children: [
                  const Text(
                    'Choose username and password',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Username',
                          style: TextStyle(fontSize: 15),
                        ),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                              suffixIcon: _usernameController.text.isNotEmpty
                                  ? _isUsernameAvailable
                                      ? const Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : const Icon(Icons.cancel,
                                          color: Colors.red)
                                  : null,
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
                              errorBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: _usernameBorderColor)),
                              errorText: _usernameErrorText.isEmpty
                                  ? null
                                  : _usernameErrorText,
                              errorStyle: TextStyle(
                                  color: !_isUsernameAvailable
                                      ? Colors.red
                                      : Colors.green)),
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                _usernameBorderColor = Colors.black;
                                _usernameErrorText = '';
                              } else if (value.length >= 6) {
                                FirestoreService.isUsernameAvailable(value)
                                    .then((available) {
                                  _isUsernameAvailable = available;

                                  if (available) {
                                    _usernameErrorText =
                                        'Username is available';
                                    _usernameBorderColor = Colors.green;
                                  } else {
                                    _usernameErrorText =
                                        'Username is already taken';
                                    _usernameBorderColor = Colors.red;
                                  }
                                });
                              } else {
                                _usernameErrorText =
                                    'Username must be at least 6 characters';
                                _isUsernameAvailable = false;
                                _usernameBorderColor = Colors.red;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  BuildTextField()
                      .fullTextFieldPassword(_passwordController, 'Password'),
                  BuildTextField().fullTextFieldPassword(
                      _confirmpassController, 'Confirm Password'),
                  const SizedBox(
                    height: 50,
                  ),
                  MaterialButton(
                    onPressed: () {
                      if (_secondPageKey.currentState!.validate()) {
                        if (_passwordController.text ==
                            _confirmpassController.text) {
                          if (_isUsernameAvailable) {
                            nextPage();
                          } else {
                            setState(() {
                              Modals.showAlert(
                                context,
                                'Username is already taken',
                                'Oops!',
                              );
                            });
                          }
                        } else {
                          setState(() {
                            _passwordController.clear();
                            _confirmpassController.clear();
                            Modals.showAlert(
                                context, 'Password doesnt match', 'Oops!');
                          });
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPage(ThemeNotifier notifier) {
    return Form(
      key: _firstPageKey,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set up profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    _showImageSourceModal(context);
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: notifier.secondaryContainer,
                    ),
                    child: Stack(
                      children: [
                        _imageFile != null
                            ? Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.file(
                                    File(_imageFile!.path),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.person,
                                  color: notifier.primary,
                                  size: 50,
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageFile = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _imageFile != null
                                    ? Colors.red
                                    : notifier.primary,
                              ),
                              child: Icon(
                                _imageFile != null ? Icons.close : Icons.image,
                                color: notifier.onPrimaryContainer,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              BuildTextField().halfedTextField(_firstNameController,
                  'First Name', _lastNameController, 'Last Name'),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Contact Number',
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCountry != null
                                ? _selectedCountry!['name']
                                : null,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  final countryList = country.getList();
                                  _selectedCountry = countryList.firstWhere(
                                    (country) => country['name'] == newValue,
                                    orElse: () => <String, String>{},
                                  );
                                });
                              }
                            },
                            items: country
                                .getList()
                                .map<DropdownMenuItem<String>>((country) {
                              return DropdownMenuItem<String>(
                                value: country['name'],
                                child: Text(
                                  '${country['acronym']} (${country['code']})',
                                  style: const TextStyle(
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  BuildTextField.expandedTextFieldContact(
                      _contactController, '')
                ],
              ),
              _buildTextField.fullTextField(
                  _streetController, 'Street Address'),
              BuildTextField().halfedTextField(
                  _zipCodeController, 'Zip Code', _cityController, 'City'),
              const SizedBox(
                height: 100,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: MaterialButton(
                  onPressed: () {
                    if (_firstPageKey.currentState!.validate()) {
                      nextPage();
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
      ),
    );
  }

  Widget _buildThirdPage(ThemeNotifier notifier) {
    return Form(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Let us know your interests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: interests
                    .map(
                      (interest) => GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected(interest)) {
                              selectedInterests.remove(interest);
                            } else {
                              selectedInterests.add(interest);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected(interest)
                                  ? notifier.primary
                                  : notifier.secondaryContainer,
                            ),
                            color: isSelected(interest)
                                ? notifier.primary
                                : notifier.secondaryContainer,
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: isSelected(interest)
                                  ? Colors.white
                                  : notifier.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(
                height: 60,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: MaterialButton(
                  onPressed: () => selectedInterests.isNotEmpty
                      ? handleRegisterClick(notifier)
                      : null,
                  height: 45,
                  color: selectedInterests.isNotEmpty
                      ? notifier.primary
                      : notifier.secondaryContainer,
                  child: const Text(
                    'FINISH',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleRegisterClick(ThemeNotifier notifier) async {
    String username = _usernameController.text;
    String email = widget.email;
    String contactNumber = _contactController.text;
    List<String> followers = [];
    List<String> following = [];
    List<String> commissions = [];
    String streetAddress = _streetController.text;
    String country = _selectedCountry!['name'] ?? '';
    double credits = 0;
    String cityAddress = _cityController.text;
    String zip = _zipCodeController.text;
    String password = _passwordController.text;
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;

    try {
      if (_imageFilePath.isNotEmpty) {
        _imageFilePath = await fireservice.uploadImageToFirebase(
            _imageFilePath, 'profileurls');
      } else {
        _imageFilePath = 'N/A';
      }
      var user = UserObject(
          dateCreated: Utils.getCurrentTime(),
          firstName: firstName,
          lastName: lastName,
          profileUrl: _imageFilePath,
          userLiked: [],
          userFavorites: [],
          followers: followers,
          following: following,
          email: email,
          username: username,
          interests: selectedInterests,
          commissions: commissions,
          contactNumber: contactNumber,
          streetAddress: streetAddress,
          cityAddress: cityAddress,
          zip: zip,
          country: country,
          credits: credits);

      // ignore: use_build_context_synchronously
      await Modals.loader(context, notifier, 'Generating your feed...', 200, 2);
      await auth.registerWithEmail(user, password);

      // ignore: use_build_context_synchronously
      PageTransitions().slideLeftToHome(context);
    } catch (e) {
      debugPrint(e.toString());

      // ignore: use_build_context_synchronously
      Modals.showAlert(context,
          'Something occured. Failed to create acount: Error: $e', 'Error');
    }
  }

  void _showImageSourceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
