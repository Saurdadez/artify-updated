// ignore_for_file: use_build_context_synchronously

import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/pages/item_expanded.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LikedPage extends StatefulWidget {
  const LikedPage({super.key});

  @override
  State<LikedPage> createState() => _LikedPageState();
}

class _LikedPageState extends State<LikedPage> {
  final fireservice = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisExtent = screenWidth / 2;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Likes',
            style: TextStyle(fontSize: 16),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.navigate_before_rounded,
              size: 25,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: StreamBuilder<List<String>>(
          stream: fireservice.getUserLikesStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No liked items'),
              );
            }
            return FutureBuilder<List<DocumentSnapshot>>(
              future: Future.wait(snapshot.data!.map((itemId) =>
                  FirebaseFirestore.instance
                      .collection('ShopItems')
                      .doc(itemId)
                      .get())),
              builder: (context, itemSnapshots) {
                if (itemSnapshots.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                if (itemSnapshots.hasError) {
                  return const Center(
                    child: Text('Error loading items'),
                  );
                }

                final existingItems =
                    itemSnapshots.data!.where((item) => item.exists).toList();

                if (existingItems.isEmpty) {
                  return const Center(
                    child: Text('No existing liked items'),
                  );
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: crossAxisExtent,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: existingItems.length,
                  itemBuilder: (context, index) {
                    final itemDoc = existingItems[index];
                    return buildShopItemGridItem(itemDoc);
                  },
                );
              },
            );
          },
        ));
  }

  Card buildShopItemGridItem(DocumentSnapshot itemDoc) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        height: 300,
        child: GestureDetector(
          onTap: () async {
            String? profile =
                await fireservice.getProfileUrl(itemDoc['userId']);
            var userinfo = await fireservice.getUserInfo(itemDoc['userId']);

            String firstName = userinfo?['firstName'];
            String lastName = userinfo?['lastName'];

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ItemExpanded(
                        email: itemDoc['userId'],
                        images: itemDoc['images'] != null
                            ? List<String>.from(itemDoc['images'])
                            : [],
                        sellerName: '$firstName $lastName',
                        title: itemDoc['title'],
                        price: (itemDoc['price'] as double).toInt(),
                        address: itemDoc['location'],
                        dateAdded: itemDoc['dateAdded'],
                        description: itemDoc['description'],
                        favoritesCount: itemDoc['favorites'].length,
                        likesCount: itemDoc['likes'].length,
                        profileUrl: profile ?? 'N/A',
                        tags: List<String>.from(itemDoc['tags']),
                        status: itemDoc['status'],
                      )),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: itemDoc['images'][0],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Consumer<ThemeNotifier>(builder: (context, notifier, child) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  color: notifier.secondaryContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              itemDoc['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          HeartToggleButton(
                            email: itemDoc['userId'],
                            title: itemDoc['title'],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Price: \$${itemDoc['price']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
