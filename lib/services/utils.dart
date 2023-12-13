// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:art_app/components/page_notifier.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/pages/login_page.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class Utils {
  static bool isUserNoProfile(String url) {
    return url.contains('N/A');
  }

  static String getTimeDifference(String dateAdded) {
    List<String> dateTimeParts = dateAdded.split(' ');
    List<String> dateParts = dateTimeParts[0].split('-');

    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    DateTime addedDate = DateTime(year, month, day);
    DateTime now = DateTime.now();
    Duration difference = now.difference(addedDate);

    if (difference.inDays > 365) {
      int years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      int months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return 'Today';
    }
  }

  static String getCurrentTime() {
    DateTime now = DateTime.now();
    String timestamp = now.toString();

    return timestamp;
  }

  static stampToMonthDayYear(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    String formattedDate = '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    return formattedDate;
  }

  static String generateRandomUsername() {
    final random = Random();
    const prefix = 'User';
    final randomNumber = random.nextInt(999999);
    return '$prefix$randomNumber';
  }
}

class CountryList {
  static final List<Map<String, String>> _countries = [
    {'name': 'Philippines', 'acronym': 'PH', 'code': '+63'},
    {'name': 'United States', 'acronym': 'US', 'code': '+1'},
  ];

  List<Map<String, String>> getList() {
    return _countries;
  }

  static String getCountryNameFromCode(String code) {
    Map<String, String>? selected = _countries.firstWhere(
      (country) => country['code'] == code,
      orElse: () => {'name': '', 'acronym': '', 'code': ''},
    );
    return selected['name']!;
  }

  static String getCountryCodeFromName(String countryName) {
    Map<String, String>? selected = _countries.firstWhere(
      (country) => country['name'] == countryName,
      orElse: () => {'name': '', 'acronym': '', 'code': ''},
    );
    return selected['code']!;
  }
}

class Modals {
  static BuildContext? modalContext;
  static Future<void> loader(BuildContext context, ThemeNotifier notifier,
      String message, int delayStart, int delayEnd) async {
    await Future.delayed(Duration(milliseconds: delayStart));

    showModalBottomSheet(
      context: context,
      backgroundColor: notifier.secondaryContainer,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
    await Future.delayed(Duration(seconds: delayEnd));
  }

  static Future<void> loaderPopupWithDuration(
      BuildContext context,
      IconData icon,
      Color color,
      String title,
      int delayStart,
      int delayEnd) async {
    await Future.delayed(Duration(milliseconds: delayStart));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Icon(
            icon,
            size: 60,
            color: color,
          ),
          content: Center(
            child: Text(title),
          ),
        );
      },
    );
    await Future.delayed(Duration(seconds: delayEnd));
  }

  static Future<void> loaderPopup(BuildContext context, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          surfaceTintColor: Theme.of(context).colorScheme.secondaryContainer,
          scrollable: true,
          content: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(message),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static showNotLoggedIn(BuildContext context) {
    return Modals.showAlertWithButton(
        context,
        'You are not logged in',
        'Please log in',
        'Go to login page',
        () => PageTransitions().slideLeftToPage(context, const LoginPage()));
  }

  static Future<void> showAlert(
      BuildContext context, String message, String title) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
              Center(
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: AlertDialog(
                    surfaceTintColor: Theme.of(context).colorScheme.tertiary,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    scrollable: true,
                    title: Center(child: Text(title)),
                    content: Center(child: Text(message)),
                    actions: <Widget>[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Center(
                              child: Text(
                            'OK',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        transitionDuration: const Duration(milliseconds: 150),
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return child;
        },
      ),
    );
  }

  static Future<void> showAlertNotify(
      BuildContext context, String message, String title) async {
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 60,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: AlertDialog(
            surfaceTintColor: Theme.of(context).colorScheme.tertiary,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            scrollable: true,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    await Future.delayed(Duration(seconds: 2));

    overlayEntry.remove();
  }

  static Future<void> showAlertWithButton(BuildContext context, String message,
      String title, String buttonText, Function() onTap) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            surfaceTintColor: Theme.of(context).colorScheme.secondaryContainer,
            scrollable: true,
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Center(child: Text(message)),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: <Widget>[
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(border: Border.all()),
                  child: Center(
                      child: Text(
                    buttonText,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showAlertConfirm(
      BuildContext context, String message, String title, Function() onTap) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: AlertDialog(
            scrollable: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: Colors.red,
                  size: 50,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Center(child: Text(message)),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: <Widget>[
              TextButton(
                onPressed: onTap,
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> expandedModal(
      BuildContext context, Widget destination, ThemeNotifier notifier) async {
    showModalBottomSheet(
      backgroundColor: notifier.primaryContainer,
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        modalContext = ctx;
        return Container(
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.only(top: 20),
          child: destination,
        );
      },
    );
  }

  Future<void> loaderResponse(BuildContext context, String message) async {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          modalContext = ctx;
          return SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(message),
                ],
              ),
            ),
          );
        });
  }

  static Future<void> loadingModal(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  void closeModal() {
    if (modalContext != null) {
      Navigator.pop(modalContext!);
      modalContext = null;
    }
  }
}

class PageTransitions {
  void slideLeftToHome(BuildContext context) async {
    var pageChangeNotifier =
        Provider.of<PageChangeNotifier>(context, listen: false);
    pageChangeNotifier.updateIndex(0);
    pageChangeNotifier.updateRefreshHome(true);
    Navigator.of(context).popUntil((route) => route.isFirst);

    pageChangeNotifier.updateRefreshHome(false);
    pageChangeNotifier.triggerRefresh(true);
    pageChangeNotifier.triggerRefresh(false);
  }

  void popToPageHome(BuildContext context, int index) async {
    var pageChangeNotifier =
        Provider.of<PageChangeNotifier>(context, listen: false);
    pageChangeNotifier.updateIndex(index);
    pageChangeNotifier.updateRefreshHome(true);
    Navigator.of(context).popUntil((route) => route.isFirst);
    pageChangeNotifier.updateRefreshHome(false);
    pageChangeNotifier.triggerRefresh(true);
    pageChangeNotifier.triggerRefresh(false);
  }

  void slideLeftToPage(context, Widget destination) async {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class CustomFadeInImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  const CustomFadeInImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  });

  @override
  CustomFadeInImageState createState() => CustomFadeInImageState();
}

class CustomFadeInImageState extends State<CustomFadeInImage> {
  bool _isCached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkCacheStatus();
  }

  Future<void> checkCacheStatus() async {
    await precacheImage(CachedNetworkImageProvider(widget.imageUrl), context);
    if (mounted) {
      setState(() {
        _isCached = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isCached ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500), // Adjust duration as needed
      curve: Curves.easeInOut, // Adjust curve as needed
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        placeholder: (context, url) => Container(
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}

class HeartToggleButton extends StatefulWidget {
  const HeartToggleButton({
    super.key,
    required this.email,
    required this.title,
    this.size,
    this.text,
  });

  final String email, title;
  final String? text;
  final double? size;

  @override
  HeartToggleButtonState createState() => HeartToggleButtonState();
}

class HeartToggleButtonState extends State<HeartToggleButton> {
  late Stream<bool> _isInLikesStream;
  @override
  void initState() {
    super.initState();
    _isInLikesStream =
        FirestoreService().checkIfInLikes(widget.email, widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _isInLikesStream,
      builder: (context, snapshot) {
        final isLiked = snapshot.data ?? false;
        return GestureDetector(
          onTap: () async {
            final loggedIn = FirebaseAuth.instance.currentUser != null;
            if (!loggedIn) {
              Modals.showNotLoggedIn(context);
              return;
            }
            if (isLiked) {
              FirestoreService().removeFromLikes(widget.email, widget.title);
            } else {
              FirestoreService().addToLikes(widget.email, widget.title);

              Modals.showAlertNotify(context, '', 'Added to likes');
            }
          },
          child: Row(
            children: [
              StreamBuilder<bool>(
                stream: _isInLikesStream,
                builder: (context, snapshot) {
                  final isLiked = snapshot.data ?? false;
                  return Image.asset(
                    isLiked
                        ? 'lib/images/icons8-heart-30.png'
                        : 'lib/images/icons8-heart-30-outlined.png',
                    height: widget.size ?? 25,
                    width: widget.size ?? 25,
                    color: isLiked
                        ? Colors.red
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(widget.text ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }
}

class FavoriteButton extends StatefulWidget {
  const FavoriteButton(
      {super.key,
      required this.email,
      required this.title,
      this.size,
      this.text});
  final String email, title;
  final String? text;
  final double? size;
  @override
  FavoriteButtonState createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> {
  Stream<bool> _isInFavoriteStream = const Stream<bool>.empty();
  @override
  void initState() {
    super.initState();
    _isInFavoriteStream =
        FirestoreService().checkIfInFavorites(widget.email, widget.title);
    text = widget.text ?? '';
  }

  late String text;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _isInFavoriteStream,
      builder: (context, snapshot) {
        bool isSaved = snapshot.data ?? false;
        String text = widget.text ?? '';

        return GestureDetector(
          onTap: () async {
            final loggedIn = FirebaseAuth.instance.currentUser != null;
            if (!loggedIn) {
              Modals.showNotLoggedIn(context);
              return;
            }

            if (isSaved) {
              FirestoreService()
                  .removeFromFavorites(widget.email, widget.title);
            } else {
              FirestoreService().addToFavorites(widget.email, widget.title);

              Modals.showAlertNotify(context, '', 'Added to favorites');
            }
          },
          child: Row(
            children: [
              SizedBox(
                width: 25,
                height: 25,
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                  size: widget.size ?? 25,
                  color: isSaved
                      ? Colors.orange
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CartToggleButton extends StatefulWidget {
  const CartToggleButton({
    super.key,
    required this.email,
    required this.title,
    this.size,
    this.text,
  });

  final String email, title;
  final double? size;
  final String? text;

  @override
  CartToggleButtonState createState() => CartToggleButtonState();
}

class CartToggleButtonState extends State<CartToggleButton> {
  late Stream<bool> _isInCartStream;
  final fireservice = FirestoreService();
  @override
  void initState() {
    super.initState();
    _isInCartStream =
        FirestoreService().checkIfInCart(widget.email, widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _isInCartStream,
      builder: (context, snapshot) {
        final isInCart = snapshot.data ?? false;
        final text = widget.text ?? '';
        return GestureDetector(
          onTap: () {
            final loggedIn = FirebaseAuth.instance.currentUser != null;
            if (!loggedIn) {
              Modals.showNotLoggedIn(context);
              return;
            }
            if (isInCart) {
              fireservice.removeFromCart(widget.email, widget.title);
            } else {
              fireservice.addToCart(widget.email, widget.title);
              Modals.showAlertNotify(
                context,
                '',
                'Added to cart',
              );
            }
            setState(() {});
          },
          child: Row(
            children: [
              SizedBox(
                width: 25,
                height: 25,
                child: Icon(
                  isInCart ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                  color: isInCart
                      ? Colors.orange
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  size: widget.size ?? 25,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SelectionCheckbox extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;

  const SelectionCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  SelectionCheckboxState createState() => SelectionCheckboxState();
}

class SelectionCheckboxState extends State<SelectionCheckbox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _isChecked,
      onChanged: (bool? newValue) {
        if (newValue != null && newValue != _isChecked) {
          setState(() {
            _isChecked = newValue;
          });
          widget.onChanged?.call(newValue);
        }
      },
    );
  }
}
