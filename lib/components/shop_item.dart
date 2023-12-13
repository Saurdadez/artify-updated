import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/pages/item_expanded.dart';
import 'package:art_app/services/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopItem extends StatefulWidget {
  const ShopItem({
    super.key,
    required this.title,
    required this.email,
    required this.username,
    required this.sellerName,
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
  final String username;
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
  State<ShopItem> createState() => _ShopItemState();
}

class _ShopItemState extends State<ShopItem> {
  var currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  List<ImageProvider> imageProviders = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ItemExpanded(
                        email: widget.email,
                        images: widget.images,
                        sellerName: widget.sellerName,
                        title: widget.title,
                        price: widget.price,
                        address: widget.address,
                        dateAdded: widget.dateAdded,
                        description: widget.description,
                        favoritesCount: widget.favoritesCount,
                        likesCount: widget.likesCount,
                        profileUrl: widget.profileUrl,
                        tags: widget.tags,
                        status: widget.status,
                      )),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 35,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child:
                                        Utils.isUserNoProfile(widget.profileUrl)
                                            ? ClipOval(
                                                child: Image.asset(
                                                    'lib/images/default_pic.png'),
                                              ) // Use Image.asset here
                                            : ClipOval(
                                                child: CustomFadeInImage(
                                                  imageUrl: widget.profileUrl,
                                                  fit: BoxFit.cover,
                                                ),
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
                                      Row(
                                        children: [
                                          Text(
                                            widget.sellerName,
                                            textAlign: TextAlign.left,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                            child: Center(
                                                child: Text('•',
                                                    style: TextStyle(
                                                        fontSize: 13))),
                                          ),
                                          Text(
                                            'Follow',
                                            style: TextStyle(
                                                color: Colors.red[400],
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.more_vert_rounded,
                                  color: notifier.onSurface,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: CustomFadeInImage(
                    imageUrl: widget.images[0],
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          HeartToggleButton(
                              email: widget.email, title: widget.title),
                          const SizedBox(width: 15),
                          CartToggleButton(
                              email: widget.email, title: widget.title),
                        ],
                      ),
                      Text("${widget.price.toString()} PHP",
                          style: const TextStyle(fontSize: 13))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Wrap(children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 2,
                          ),
                        ]),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 50),
                        child: Text(
                          widget.description,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class ShopItemTIledSmall extends StatefulWidget {
  const ShopItemTIledSmall({
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
  State<ShopItemTIledSmall> createState() => _ShopItemTIledSmallState();
}

class _ShopItemTIledSmallState extends State<ShopItemTIledSmall> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemExpanded(
              email: widget.email,
              images: widget.images,
              sellerName: widget.sellerName,
              title: widget.title,
              price: widget.price,
              address: widget.address,
              dateAdded: widget.dateAdded,
              description: widget.description,
              favoritesCount: widget.favoritesCount,
              likesCount: widget.likesCount,
              profileUrl: widget.profileUrl,
              tags: widget.tags,
              status: widget.status,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 250,
        width: MediaQuery.of(context).size.width / 3 - 2,
        child: CachedNetworkImage(
          imageUrl: widget.images[0],
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ShopItemTiledSmallText extends StatefulWidget {
  const ShopItemTiledSmallText({
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
  State<ShopItemTiledSmallText> createState() => _ShopItemTiledSmallTextState();
}

class _ShopItemTiledSmallTextState extends State<ShopItemTiledSmallText> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemExpanded(
              email: widget.email,
              images: widget.images,
              sellerName: widget.sellerName,
              title: widget.title,
              price: widget.price,
              address: widget.address,
              dateAdded: widget.dateAdded,
              description: widget.description,
              favoritesCount: widget.favoritesCount,
              likesCount: widget.likesCount,
              profileUrl: widget.profileUrl,
              tags: widget.tags,
              status: widget.status,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 250,
        width: MediaQuery.of(context).size.width / 3 - 2,
        child: CachedNetworkImage(
          imageUrl: widget.images[0],
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
