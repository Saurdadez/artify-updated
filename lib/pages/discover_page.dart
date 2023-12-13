import 'package:art_app/components/page_notifier.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/models/shop_item_model.dart';
import 'package:art_app/pages/item_expanded.dart';
import 'package:art_app/pages/profile_page.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final fireservice = FirestoreService();
  List<ShopItemModel> shopItems = [];
  List<Map<String, dynamic>?> topartists = [];
  bool isFollowing = false;
  @override
  void initState() {
    super.initState();
    fireservice.getArtistPicks().then((items) {
      setState(() {
        shopItems = items;
      });
    }).catchError((error) {
      debugPrint('Error fetching artist picks: $error');
    });
    fireservice.getTopArtists().then((topartist) {
      setState(() {
        topartists = topartist;
      });
    }).catchError((error) {
      debugPrint('Error fetching top artist: $error');
    });
  }

  void pageRefresh() async {
    if (Provider.of<PageChangeNotifier>(context, listen: false).shouldRefresh) {
      setState(() {
        shopItems = [];
      });

      fireservice.getArtistPicks().then((items) {
        setState(() {
          shopItems = items;
        });
      }).catchError((error) {
        debugPrint('Error fetching artist picks: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<PageChangeNotifier>(context, listen: false)
        .addListener(pageRefresh);
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: notifier.background,
          title: const Text('Categories'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategory(
                        'Painting',
                        'https://source.unsplash.com/featured/?painting',
                      ),
                      _buildCategory(
                        'Digital Art',
                        'https://source.unsplash.com/featured/?digital-art',
                      ),
                      _buildCategory(
                        'Classical Art',
                        'https://source.unsplash.com/featured/?classical-art',
                      ),
                      _buildCategory(
                        'Modernism',
                        'https://source.unsplash.com/featured/?modern-art',
                      ),
                      _buildCategory(
                        'Interior',
                        'https://source.unsplash.com/featured/?interior-art',
                      ),
                      _buildCategory(
                        'Sculpture',
                        'https://source.unsplash.com/featured/?sculpture',
                      ),
                      _buildCategory(
                        'Fine Arts',
                        'https://source.unsplash.com/featured/?fine-art',
                      ),
                      _buildCategory(
                        'Abstract Art',
                        'https://source.unsplash.com/featured/?abstract-art',
                      ),
                      _buildCategory(
                        'Photography',
                        'https://source.unsplash.com/featured/?photography',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(12.0, 15, 12, 15),
                  child: const Text(
                    "Artists' Picks",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 330,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: shopItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildPictureContainer(shopItems[index]);
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "Top Artists",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                _buildTopArtists(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCategory(
    String categoryName,
    String imageUrl,
  ) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => {},
          child: Container(
            // diri imong image

            height: 200,
            margin: const EdgeInsets.only(right: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: CachedNetworkImage(
                height: 150.0,
                width: 200.0,
                fit: BoxFit.cover,
                imageUrl: imageUrl,
              ),
            ),
          ),
        ),
        Positioned(
          // mao ni ang gradient bottom to top
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              // imong mga text
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPictureContainer(ShopItemModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => ItemExpanded(
                    title: item.title,
                    sellerName: item.sellerName,
                    email: item.email,
                    description: item.description,
                    favoritesCount: item.favoritesCount,
                    likesCount: item.likesCount,
                    profileUrl: item.profileUrl,
                    tags: item.tags,
                    images: item.images,
                    price: item.price,
                    address: item.address,
                    status: item.status,
                    dateAdded: item.dateAdded)));
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CustomFadeInImage(
                imageUrl: item.images.isNotEmpty ? item.images[0] : '',
                fit: BoxFit.cover,
              ),
            ),
            /*
            Image.network(
              item.images.isNotEmpty ? item.images[0] : '',
              height: 200.0,
              width: 400.0,
              fit: BoxFit.cover,
            ),
            */
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        'By ${item.sellerName}',
                        style: const TextStyle(
                          fontSize: 13.0,
                        ),
                      ),
                      Text(
                        'Price \$${item.price}',
                        style: const TextStyle(
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  HeartToggleButton(email: item.email, title: item.title),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopArtists() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topartists.length,
              itemBuilder: (context, index) {
                final artist = topartists[index];
                if (artist == null) {
                  return const SizedBox();
                }
                final title = '${artist['firstName']} ${artist['lastName']}';
                var followers = artist['followers'] ?? [];
                final followerCount = followers.length;
                final profileUrl = artist['profileurl'];

                return GestureDetector(
                  onTap: () {
                    PageTransitions().slideLeftToPage(
                        context,
                        ProfilePage(
                          fetchedProfile: artist,
                        ));
                  },
                  child: ListTile(
                    leading: profileUrl != 'N/A'
                        ? Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(profileUrl),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('lib/images/default_pic.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    subtitle: Text(
                      '$followerCount Followers',
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    trailing: StreamBuilder<bool>(
                      stream:
                          FirestoreService().isFollowingUser(artist['email']),
                      builder: (context, isFollowingSnapshot) {
                        isFollowing = isFollowingSnapshot.data ?? false;

                        return GestureDetector(
                          onTap: () async {
                            final loggedin =
                                FirebaseAuth.instance.currentUser != null;
                            if (!loggedin) {
                              Modals.showNotLoggedIn(context);
                              return;
                            }

                            isFollowing
                                ? FirestoreService()
                                    .deleteFollower(artist['email'])
                                : FirestoreService()
                                    .addFollower(artist['email']);

                            setState(() {
                              isFollowing = !isFollowing;
                            });
                          },
                          child: Container(
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Color.fromARGB(255, 46, 46, 46)),
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
