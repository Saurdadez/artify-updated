// ignore_for_file: use_build_context_synchronously

import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddToCart extends StatefulWidget {
  const AddToCart({super.key});

  @override
  AddToCartState createState() => AddToCartState();
}

class AddToCartState extends State<AddToCart> {
  final List<Map<String, dynamic>> selectedItems = [];

  final cartCollection = FirebaseFirestore.instance.collection('Cart');
  final currentUserId = FirebaseAuth.instance.currentUser?.email;
  late List<Map<String, dynamic>> initialShopItems = [];
  late bool loading = true;
  double total = 0.0;
  Future<String> profileurl(String email) async {
    var url = await FirestoreService().getProfileUrl(email);
    return url ?? 'N/A';
  }

  Future<void> _fetchInitialShopItems() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final snapshot =
          await cartCollection.where('userId', isEqualTo: currentUserId).get();

      final cartDocs = snapshot.docs;
      List<Map<String, dynamic>> shopItems = [];

      for (var cartDoc in cartDocs) {
        final cartData = cartDoc.data();
        final List<dynamic> items = cartData['items'] ?? [];

        final itemSnapshot = await FirebaseFirestore.instance
            .collection('ShopItems')
            .where(FieldPath.documentId, whereIn: items)
            .get();

        shopItems.addAll(
          itemSnapshot.docs.map((shopItem) => shopItem.data()),
        );
      }

      setState(() {
        loading = false;
        initialShopItems = List<Map<String, dynamic>>.from(shopItems);
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialShopItems();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: notifier.background,
          title: const Text('My Cart'),
          leading: IconButton(
            icon: const Icon(
              Icons.navigate_before_rounded,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: initialShopItems.isEmpty
            ? loading
                ? const Center(child: CircularProgressIndicator())
                : const Center(child: Text('No items in cart'))
            : ListView.builder(
                itemCount: initialShopItems.length,
                itemBuilder: (context, index) {
                  final shopItem = initialShopItems[index];
                  final imgurl = shopItem['images'][0];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      tileColor: notifier.secondaryContainer,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SelectionCheckbox(
                            isChecked: selectedItems.any((item) =>
                                item['userId'] == shopItem['userId'] &&
                                item['title'] == shopItem['title']),
                            onChanged: (bool? value) {
                              if (value != null) {
                                bool itemExists = selectedItems.any((item) =>
                                    item['userId'] == shopItem['userId'] &&
                                    item['title'] == shopItem['title']);

                                if (itemExists) {
                                  selectedItems.removeWhere((item) =>
                                      item['userId'] == shopItem['userId'] &&
                                      item['title'] == shopItem['title']);
                                  setState(() {
                                    total -= shopItem['price'];
                                  });
                                } else {
                                  selectedItems.add(shopItem);
                                  setState(() {
                                    total += shopItem['price'];
                                  });
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 100,
                            height: 400,
                            child: CachedNetworkImage(
                              imageUrl: imgurl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        shopItem['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 2,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shopItem['artist'],
                            style: TextStyle(color: notifier.onSecondary),
                          ),
                          Text("\$${shopItem['price'].toStringAsFixed(2)}",
                              style: TextStyle(color: notifier.onSecondary)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.remove_circle,
                          color: notifier.secondary,
                        ),
                        onPressed: () async {
                          setState(() {
                            initialShopItems.remove(shopItem);
                            selectedItems.removeWhere((item) =>
                                item['userId'] == shopItem['userId'] &&
                                item['title'] == shopItem['title']);
                            setState(() {
                              if (total != 0) total -= shopItem['price'];
                            });
                          });

                          FirestoreService().removeFromCart(
                            shopItem['userId'],
                            shopItem['title'],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Total : \$${total.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: notifier.secondaryContainer),
                child: MaterialButton(
                  animationDuration: const Duration(seconds: 5),
                  onPressed: () async {
                    final itemsToRemove =
                        List<Map<String, dynamic>>.from(selectedItems);
                    final updatedShopItems =
                        List<Map<String, dynamic>>.from(initialShopItems);

                    double totalPriceToRemove = 0.0;
                    // Calculate the total price of selected items to be removed
                    for (var item in itemsToRemove) {
                      totalPriceToRemove += item['price'];
                    }

                    setState(() {
                      updatedShopItems.removeWhere((item) => itemsToRemove.any(
                          (selected) =>
                              selected['userId'] == item['userId'] &&
                              selected['title'] == item['title']));
                      initialShopItems = updatedShopItems;
                      selectedItems.clear();
                      total -= totalPriceToRemove;
                      if (updatedShopItems.isEmpty) {
                        loading = false;
                      }
                    });
                    Modals.loaderPopup(
                      context,
                      'Please wait...',
                    );
                    for (var item in itemsToRemove) {
                      await FirestoreService()
                          .markOrderSold(item['title'], item['userId']);
                      await FirestoreService()
                          .removeFromCart(item['userId'], item['title']);
                    }
                    Navigator.pop(context);
                    await Modals.loaderPopupWithDuration(
                        context,
                        Icons.check_circle_outline_rounded,
                        Colors.green,
                        'Order Placed',
                        1,
                        2);
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Checkout',
                        style: TextStyle(color: notifier.primary),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Icon(
                        Icons.shopping_cart_checkout,
                        color: notifier.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
