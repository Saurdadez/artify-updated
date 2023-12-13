import 'package:art_app/components/collection_item_widget.dart';
import 'package:art_app/components/page_notifier.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/pages/account_page.dart';
import 'package:art_app/pages/commissions_page.dart';
import 'package:art_app/pages/book_commission_page.dart';
import 'package:art_app/pages/editprofile_page.dart';
import 'package:art_app/pages/not_signed_in_page.dart';
import 'package:art_app/services/auth_service.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
      {super.key, this.email, this.fetchedProfile, this.wasPushed = false});
  final bool wasPushed;
  final String? email;
  final Map<String, dynamic>? fetchedProfile;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirestoreService firestoreService = FirestoreService();
  final fireservice = FirestoreService();

  Map<String, dynamic>? fetchedProfile;
  late String currentEmail;
  int onPage = 0;
  late bool isCurrentUserEmail;
  bool isfollowing = false;
  bool _showBackButton = false;
  final _profileScrollController = ScrollController();
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    isCurrentUserEmail =
        (widget.fetchedProfile == null || widget.fetchedProfile!.isEmpty);
    if (isCurrentUserEmail) {
      fetchUserProfile();
    } else {
      fetchedProfile = widget.fetchedProfile;
    }
    if (widget.wasPushed) {
      _showBackButton = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      Provider.of<PageChangeNotifier>(context, listen: true)
          .addListener(profilePageRefresh);
    } else {
      Provider.of<PageChangeNotifier>(context, listen: false)
          .removeListener(profilePageRefresh);
    }
  }

  void profilePageRefresh() {
    if (mounted) {
      setState(() {
        fetchUserProfile();
      });
    }
  }

  Future<void> fetchUserProfile() async {
    if (mounted) {
      var currentUserEmail = await AuthService().getCurrentUserEmail();
      var userProfile =
          await FirestoreService().getUserInfo(currentUserEmail ?? '');
      setState(() {
        fetchedProfile = userProfile;
      });
    }
  }

  void navigateToPage(int page) {
    onPageChanged(page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int page) {
    setState(() {
      onPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
            if (snapshot.hasData || widget.fetchedProfile != null) {
              User? currentUser = snapshot.data;

              if ((currentUser != null || widget.fetchedProfile != null)) {
                return Scaffold(
                  body: DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                      controller: _profileScrollController,
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            floating: true,
                            surfaceTintColor: notifier.surface,
                            leading: _showBackButton
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.navigate_before_rounded,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                : null,
                            snap: true,
                            elevation: 0.0,
                            toolbarHeight: 70,
                            title: Text(
                              isCurrentUserEmail
                                  ? 'My Collection'
                                  : "Collection",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            actions: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              const AccountPage())),
                                  child: const Icon(Icons.menu_rounded),
                                ),
                              ),
                            ],
                          ),
                          SliverToBoxAdapter(child: buildUserProfile(context)),
                        ];
                      },
                      body: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          navigateToPage(index);
                        },
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: fireservice.streamShopItemsOfUser(
                                fetchedProfile?['email'] ?? ''),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'Uh oh! You have no post yet :)',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                );
                              }

                              List<DocumentSnapshot> shopItems =
                                  snapshot.data!.docs;

                              return GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  childAspectRatio: .9,
                                ),
                                itemCount: shopItems.length,
                                itemBuilder: (context, index) {
                                  return buildUserShopItemSmall(
                                      shopItems[index]);
                                },
                              );
                            },
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: fireservice.streamAvailableShopItemsOfUser(
                                fetchedProfile?['email'] ?? ''),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center();
                              }

                              List<DocumentSnapshot> shopItems =
                                  snapshot.data!.docs;

                              return GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  childAspectRatio: .9,
                                ),
                                itemCount: shopItems.length,
                                itemBuilder: (context, index) {
                                  return buildUserShopItemSmall(
                                      shopItems[index]);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const Text('Error checking your account');
              }
            } else {
              return const ProfileUnsigned();
            }
          });
    });
  }

  Widget buildUserShopItemSmall(DocumentSnapshot item) {
    return UserShopItemSmall(
      email: item['userId'],
      title: item['title'],
      sellerName: item['artist'],
      description: item['description'],
      favoritesCount: (item['favorites'] as List<dynamic>?)?.length ?? 0,
      likesCount: (item['likes'] as List<dynamic>?)?.length ?? 0,
      profileUrl: fetchedProfile?['profileurl'],
      tags: (item['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      images: (item['images'] as List<dynamic>?)?.cast<String>() ?? [],
      price: (item['price'] as num?)?.toInt() ?? 0,
      address: item['location'],
      status: item['status'] ?? '',
      dateAdded: item['dateAdded'] ?? '',
    );
  }

  Widget buildUserProfile(BuildContext context) {
    String? profileUrl = fetchedProfile?['profileurl'] as String?;
    String imageUrl = profileUrl != null && profileUrl != 'N/A'
        ? profileUrl
        : 'lib/images/default_pic.png';
    bool isFromAsset = imageUrl.startsWith('lib') ? true : false;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10),
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: !isFromAsset
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(imageUrl),
                        )
                      : DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(imageUrl),
                        ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: buildUserDetails(),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: buildActionButtons(context),
          ),
          const SizedBox(
            height: 25,
          ),
          buildTabButtons(),
        ],
      ),
    );
  }

  Widget buildUserDetails() {
    if (fetchedProfile != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${fetchedProfile?['firstName']} ${fetchedProfile?['lastName']}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
          ),
          Text(
            "@${fetchedProfile!['username'] ?? ''} ",
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Followers'),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: fireservice
                          .streamUser(fetchedProfile?['email'] ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          int followersCount = 0;
                          for (var doc in snapshot.data!.docs) {
                            var data = doc.data();

                            var followers = data['followers'];

                            if (followers != null && followers is List) {
                              followersCount += followers.length;
                            }
                          }

                          return Text(
                            followersCount.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        } else {
                          return const Text(
                            '0',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sold'),
                  StreamBuilder<QuerySnapshot>(
                    stream: fireservice
                        .streamSoldShopItemsOfUser(fetchedProfile?['email']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var soldItems = snapshot.data!.docs;
                        return Text(
                          soldItems.length.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        );
                      } else {
                        return const Text(
                          '0',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        );
                      }
                    },
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(height: 20),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildActionButtons(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isCurrentUserEmail) {
                  Modals.expandedModal(
                      context,
                      EditProfile(
                        fetchedProfile: fetchedProfile,
                      ),
                      notifier);
                } else {
                  setState(() {
                    try {
                      if (!isfollowing) {
                        if (currentEmail.isNotEmpty) {
                          FirestoreService()
                              .addFollower(fetchedProfile?['email']);
                        } else {
                          Modals.showNotLoggedIn(context);
                        }
                      } else {
                        FirestoreService()
                            .deleteFollower(fetchedProfile?['email']);
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                      return;
                    }
                  });
                }
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color.fromARGB(255, 53, 53, 53)),
                ),
                child: Center(
                  child: isCurrentUserEmail
                      ? const Text('Edit Profile')
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream:
                              fireservice.streamUser(fetchedProfile?['email']),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final data = snapshot.data!.docs.first.data();
                              final followers =
                                  data['followers'] as List<dynamic>?;

                              if (followers != null &&
                                  followers.contains(currentEmail)) {
                                isfollowing = true;
                                return const Text(
                                  'Unfollow',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                );
                              } else {
                                isfollowing = false;
                                return const Text(
                                  'Follow',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                );
                              }
                            } else {
                              return const Text(
                                'Follow',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              );
                            }
                          },
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (currentEmail.isEmpty) {
                    Modals.showNotLoggedIn(context);
                    return;
                  } else if (fetchedProfile?['email'] != currentEmail) {
                    Modals.expandedModal(
                        context,
                        BookCommissionPage(email: fetchedProfile?['email']),
                        notifier);
                    return;
                  } else {
                    Modals.expandedModal(
                        context, const CommissionsPage(), notifier);
                    return;
                  }
                });
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: notifier.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isCurrentUserEmail
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.view_comfortable_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Commissions',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      : const Text(
                          'Book a commission',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget buildTabButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () => navigateToPage(0),
          child: Text(
            'My Collection',
            style: TextStyle(
                fontSize: 15,
                fontWeight: onPage == 0 ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToPage(1),
          child: Text(
            'Selling',
            style: TextStyle(
              fontSize: 15,
              fontWeight: onPage == 1 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
