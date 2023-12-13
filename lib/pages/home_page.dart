import 'dart:async';
import 'package:art_app/components/page_notifier.dart';
import 'package:art_app/components/shop_item.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/models/shop_item_model.dart';
import 'package:art_app/pages/addtocart_page.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Filters {
  Filters();
  List<String> filter = [];

  List<String> getFilter() {
    return filter;
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();
  int fetchedItems = 0;
  final fireservice = FirestoreService();
  bool isSearching = false;
  bool isLoading = true;

  List<String> categories = [];
  List<ShopItemModel> items = [];
  List<ShopItemModel> originalItems = [];
  List<ShopItemModel> displayedItems = [];

  @override
  void dispose() {
    Provider.of<PageChangeNotifier>(context, listen: false)
        .removeListener(() {});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fireservice.getCategoriesAsList().then((retrievedCategories) {
      if (retrievedCategories.isNotEmpty) {
        setState(() {
          categories = retrievedCategories;
        });
      }
    });
    fireservice.fetchShopItems((result) {
      if (result.isNotEmpty) {
        setState(() {
          items = result;
          originalItems = List<ShopItemModel>.from(items);
          fetchedItems = items.length;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      Provider.of<PageChangeNotifier>(context, listen: false).addListener(() {
        if (Provider.of<PageChangeNotifier>(context, listen: false)
            .shouldRefreshHome) {
          if (_scrollController.hasClients && _scrollController.offset != 0.0) {
            scrollToTop();
          } else {
            refresh();
          }
        }
      });
    }
  }

  Future<void> scrollToTop() async {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  Future<void> refresh() async {
    if (mounted) {
      setState(() {
        items = [];
      });
      items = await fireservice.fetchShopItems((result) {
        setState(() {
          originalItems = List<ShopItemModel>.from(items);

          items = result;
        });
      });
    }
  }

  var filter = Filters().getFilter();
  bool isSelected(String interest) {
    return filter.contains(interest);
  }

  void filterItems() {
    setState(() {
      if (filter.isNotEmpty) {
        items = originalItems.where((item) {
          return item.tags.any((tag) => filter.contains(tag));
        }).toList();
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () => refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                surfaceTintColor: notifier.surface,
                forceMaterialTransparency: false,
                title: Text(
                  'artify',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      fontStyle: FontStyle.italic,
                      color: notifier.onPrimaryContainer,
                      letterSpacing: 3),
                ),
                floating: true,
                snap: true,
                foregroundColor: notifier.primary,
                actions: displayActions(notifier),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    children: categories.map((category) {
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected(category)) {
                                  filter.remove(category);
                                  filterItems();

                                  if (filter.isEmpty) {
                                    items = List.from(originalItems);
                                  }
                                } else {
                                  filter.add(category);
                                  filterItems();
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected(category)
                                    ? notifier.primary
                                    : notifier.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected(category)
                                      ? Colors.white
                                      : notifier.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (items.isEmpty && filter.isNotEmpty) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: Text('No items found.'),
                        ),
                      );
                    }
                    if (items.isNotEmpty) {
                      return ShopItem(
                        email: items[index].email,
                        images: items[index].images,
                        dateAdded: items[index].dateAdded,
                        username: items[index].username,
                        title: items[index].title,
                        sellerName: items[index].sellerName,
                        price: items[index].price,
                        status: items[index].status,
                        address: items[index].address,
                        description: items[index].description,
                        favoritesCount: items[index].favoritesCount,
                        likesCount: items[index].likesCount,
                        profileUrl: items[index].profileUrl,
                        tags: items[index].tags,
                      );
                    } else if (items.isEmpty && filter.isEmpty) {
                      if (index < 2) {
                        return Shimmer.fromColors(
                            baseColor: const Color.fromARGB(255, 26, 26, 26),
                            highlightColor:
                                const Color.fromARGB(255, 47, 47, 47),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey[200]),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                width: 150,
                                                height: 20,
                                                color: Colors.grey[200],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                                Container(
                                  height: 350,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(15, 0, 15, 15),
                                  height: 20,
                                  width: 250,
                                  color: Colors.grey[200],
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(15, 0, 15, 30),
                                  height: 20,
                                  width: 150,
                                  color: Colors.grey[200],
                                ),
                              ],
                            ));
                      }
                    }
                    return null;
                  },
                  childCount: items.isNotEmpty
                      ? items.length
                      : (filter.isNotEmpty ? 1 : 3),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<Widget>? displayActions(ThemeNotifier notifier) {
    return [
      IconButton(
        icon: Icon(
          Icons.notifications_none_rounded,
          size: 27,
          color: notifier.onPrimaryContainer,
        ),
        onPressed: () {},
      ),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Cart')
            .where('userId',
                isEqualTo: FirebaseAuth.instance.currentUser?.email ?? '')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          int itemCount = snapshot.data?.docs.isNotEmpty ?? false
              ? snapshot.data!.docs.first['items'].length
              : 0;

          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    size: 27,
                    color: notifier.onPrimaryContainer,
                  ),
                  onPressed: () {
                    final currentUser =
                        FirebaseAuth.instance.currentUser?.email ?? '';
                    if (currentUser.isEmpty) {
                      Modals.showNotLoggedIn(context);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddToCart(),
                      ),
                    );
                  },
                ),
              ),
              if (itemCount >
                  0) // Display the count only if it's greater than zero
                Positioned(
                  right: 10,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      )
    ];
  }
}
