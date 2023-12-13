import 'package:art_app/components/image_carousel.dart';
import 'package:art_app/components/item_details_widget.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/pages/addtocart_page.dart';
import 'package:art_app/pages/profile_page.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemExpanded extends StatefulWidget {
  const ItemExpanded({
    super.key,
    required this.title,
    required this.sellerName,
    required this.email,
    required this.description,
    required this.favoritesCount,
    required this.likesCount,
    required this.profileUrl,
    required this.tags,
    required this.images,
    required this.price,
    required this.address,
    required this.status,
    required this.dateAdded,
  });

  final String title;
  final String email;
  final String sellerName;
  final String description;
  final int favoritesCount;
  final int likesCount;
  final String profileUrl;
  final List<String> tags;
  final List<String> images;
  final int price;
  final String status;
  final String address;
  final String dateAdded;

  @override
  State<ItemExpanded> createState() => ItemExpandedState();
}

class ItemExpandedState extends State<ItemExpanded> {
  var _pageController = PageController();
  var _scrollController = ScrollController();
  var screenheight = 0.0;
  bool isFollowing = false;
  bool isScrollEnabled = false;
  List<ImageProvider> imageProviders = [];
  late Map<String, dynamic>? fetchedProfile;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    fetchUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    preloadImages();
  }

  Future<void> fetchUserProfile() async {
    if (mounted) {
      var profile = await FirestoreService().getUserInfo(widget.email);
      setState(() {
        fetchedProfile = profile;
      });
    }
  }

  void preloadImages() {
    for (var imageUrl in widget.images) {
      precacheImage(CachedNetworkImageProvider(imageUrl), context);
      precacheImage(NetworkImage(imageUrl), context);
      imageProviders.add(CachedNetworkImageProvider(imageUrl));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isFromAsset = widget.profileUrl.contains('N/A');
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.navigate_before_rounded,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                expandedHeight: MediaQuery.of(context).size.height / 2,
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      '${currentImageIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                flexibleSpace: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: PageView.builder(
                    itemCount: widget.images.length,
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      return ImageCarousel(
                        currentIndex: index,
                        imgProviders: imageProviders,
                      );
                    },
                    onPageChanged: (value) {
                      setState(() {
                        currentImageIndex = value;
                      });
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25, 15, 25, 150),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HeartToggleButton(
                                email: widget.email,
                                title: widget.title,
                                text: 'Like',
                                size: 20),
                            const SizedBox(
                              width: 8,
                            ),
                            FavoriteButton(
                              email: widget.email,
                              title: widget.title,
                              size: 20,
                              text: 'Save',
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                        Text(widget.sellerName,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        Wrap(
                          runSpacing: 10,
                          children: [
                            ItemDetail(
                                value: widget.tags.join(', '), text: 'Tags'),
                            ItemDetail(value: widget.price, text: 'Price'),
                            ItemDetail(
                                value:
                                    Utils.getTimeDifference(widget.dateAdded),
                                text: 'Price'),
                            ItemDetail(
                                value: widget.address.contains('N/A')
                                    ? 'Not specified'
                                    : widget.address,
                                text: 'Location'),
                          ],
                        ),
                        const Divider(
                          color: Color.fromARGB(255, 64, 64, 64),
                          thickness: 1,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            'About the artwork',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                        ),
                        Text(widget.description,
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 16)),
                        const Divider(
                          color: Color.fromARGB(255, 64, 64, 64),
                          thickness: 1,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            'The artist',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (fetchedProfile == null) {
                              Modals.loadingModal(context);

                              await Future.delayed(const Duration(seconds: 2));

                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }
                            // ignore: use_build_context_synchronously
                            PageTransitions().slideLeftToPage(
                                context,
                                ProfilePage(
                                  fetchedProfile: fetchedProfile,
                                  email: widget.email,
                                  wasPushed: true,
                                ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  isFromAsset
                                      ? Container(
                                          height: 60,
                                          width: 60,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                      'lib/images/default_pic.png'))))
                                      : CircleAvatar(
                                          radius:
                                              30, // Adjust the radius as needed
                                          backgroundColor: Colors
                                              .transparent, // Ensure the background is transparent for the image to be visible
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                            widget.profileUrl,
                                          ),
                                        ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.sellerName,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      StreamBuilder<int>(
                                        stream: FirestoreService()
                                            .getFollowerCountForUser(
                                                widget.email),
                                        builder: (context, snapshot) {
                                          int followerCount =
                                              snapshot.data ?? 0;
                                          return Text(
                                            '$followerCount Followers',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              StreamBuilder<bool>(
                                stream: FirestoreService()
                                    .isFollowingUser(widget.email),
                                builder: (context, isFollowingSnapshot) {
                                  isFollowing =
                                      isFollowingSnapshot.data ?? false;

                                  return GestureDetector(
                                    onTap: () async {
                                      final loggedin =
                                          FirebaseAuth.instance.currentUser !=
                                              null;
                                      if (!loggedin) {
                                        Modals.showNotLoggedIn(context);
                                        return;
                                      }

                                      isFollowing
                                          ? FirestoreService()
                                              .deleteFollower(widget.email)
                                          : FirestoreService()
                                              .addFollower(widget.email);

                                      setState(() {
                                        isFollowing = !isFollowing;
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Center(
                                        child: Text(
                                          isFollowing ? 'Following' : 'Follow',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 10,
            left: 10,
            child: Container(
              height: 120,
              color: notifier.surface,
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "PHP ₱${widget.price.toString()} ",
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                    onTap: () {
                      final loggedIn =
                          FirebaseAuth.instance.currentUser != null;
                      if (!loggedIn) {
                        Modals.showNotLoggedIn(context);
                        return;
                      }

                      FirestoreService().addToCart(widget.email, widget.title);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddToCart()));
                    },
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                          color: notifier.primary,
                          border: Border.all(width: 2, color: notifier.primary),
                          borderRadius: BorderRadius.circular(30)),
                      child: const Center(
                        child: Text(
                          'Purchase now',
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
      );
    });
  }
}
