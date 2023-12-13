// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:art_app/components/tag_capsule.dart';
import 'package:art_app/components/text_fields.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/models/shop_item_model.dart';
import 'package:art_app/pages/login_page.dart';
import 'package:art_app/services/auth_service.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<XFile> _images = [];
  final fireservice = FirestoreService();
  List<String> interests = [];
  final cropper = ImageCropper();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void pickMultipleImages() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    setState(() {
      _images.addAll(pickedImages);
    });
  }

  void displayTag() {
    if (_tagController.text.isNotEmpty) {
      interests.add(_tagController.text);
      _tagController.clear();
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  void cropImage(XFile imageFile, index) async {
    var cropped = await cropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
    );

    if (cropped != null) {
      setState(() {
        _images[index] = XFile(cropped.path);
      });
    }
  }

  void deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          surfaceTintColor: notifier.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Add Post',
            textAlign: TextAlign.center,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  postItemToFirestore();
                },
                child: Text(
                  'Post',
                  style: TextStyle(color: notifier.primary, fontSize: 15),
                ),
              ),
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: kToolbarHeight),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 330,
                  color: Colors.grey[200],
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: (_images.length) + 1,
                    itemBuilder: (context, index) {
                      if (index < (_images.length)) {
                        return _buildImagePreview(
                            _images[index], index, notifier);
                      } else {
                        if (_images.isEmpty) {
                          return GestureDetector(
                            onTap: () async {
                              pickMultipleImages();
                            },
                            child: Container(
                              width: double.infinity,
                              color: notifier.secondaryContainer,
                              height: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.library_add_sharp,
                                    size: 45,
                                    color: notifier.primary,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'Add photos',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: notifier.onSecondary),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () async {
                              pickMultipleImages();
                            },
                            child: Container(
                              color: notifier.primaryContainer,
                              child: const Center(
                                child: Icon(Icons.library_add_sharp),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildTextField()
                            .fullTextFormField(_titleController, 'Title'),
                        const SizedBox(
                          height: 15,
                        ),
                        BuildTextField().fullTextFormField(
                            _descriptionController, 'Description'),
                        const SizedBox(
                          height: 15,
                        ),
                        BuildTextField()
                            .fullTextFormFieldNumber(_priceController, 'Price'),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tags',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              TagDisplay(
                                interests: interests,
                                onDelete: (String deletedTag) {
                                  setState(() {
                                    interests.remove(deletedTag);
                                  });
                                },
                                onTagAdded: (String addedTag) {
                                  setState(() {
                                    interests.add(addedTag);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  void postItemToFirestore() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_titleController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          _priceController.text.isEmpty) {
        Modals.showAlert(context, 'Please fill all fields', 'Oops!');
        return;
      }

      if (_images.isEmpty) {
        Modals.showAlert(context, 'Please upload an image', 'Oops!');
        return;
      }

      List<String> uploadedImageUrls = [];
      String? currentUserEmail = await AuthService().getCurrentUserEmail();

      if (currentUserEmail != null) {
        Modals.loadingModal(context);

        for (XFile image in _images) {
          String imageUrl =
              await fireservice.uploadImageToFirebase(image.path, 'ShopItem');
          uploadedImageUrls.add(imageUrl);
        }

        Map<String, dynamic>? userInfo =
            await fireservice.getUserInfo(currentUserEmail);

        if (userInfo != null) {
          String firstName = userInfo['firstName'] ?? '';
          String lastName = userInfo['lastName'] ?? '';
          String artist = '$firstName $lastName';
          String cityAddress =
              userInfo['cityAddress'] != 'N/A' ? userInfo['cityAddress'] : ' ';

          double price = double.tryParse(_priceController.text) ?? 0.0;
          PostShopITem newItem = PostShopITem(
            location: "${userInfo['country']}, $cityAddress",
            title: _titleController.text,
            description: _descriptionController.text,
            price: price,
            artist: artist,
            likes: [],
            status: 'Available',
            tags: interests,
            userId: currentUserEmail,
            dateAdded: Utils.getCurrentTime(),
            favorites: [],
            images: uploadedImageUrls,
          );
          Navigator.pop(context);

          await fireservice.addShopItem(newItem).then((_) async {
            await Modals.showAlert(
                context, 'Successfully posted', 'Great news!');
            Navigator.pop(context);
          }).catchError((error) {
            Modals.showAlert(context,
                'Somethin went wrong. Check your connection.', 'Oops!');
          });
        }
       
      } else {
        Modals.showAlertWithButton(
            context,
            'You are not logged in. ',
            'Oops!',
            'Go to login',
            () => {
                  PageTransitions().slideLeftToPage(context, const LoginPage()),
                });
      }
    }
  }

  Widget _buildImagePreview(XFile imageFile, index, ThemeNotifier notifier) {
    return Center(
      child: Container(
        color: notifier.primaryContainer,
        width: double.infinity,
        child: Stack(
          children: [
            Center(
              child: Image.file(
                File(imageFile.path),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.crop),
                      onPressed: () {
                        cropImage(imageFile, index);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outlined),
                      onPressed: () {
                        deleteImage(index);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
