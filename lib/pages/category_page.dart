import 'dart:async';

import 'package:art_app/components/shop_item.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/models/shop_item_model.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.categoryName});

  final String categoryName;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<ShopItemModel>> itemsFuture;
  final fireservice = FirestoreService();
  @override
  void initState() {
    super.initState();
    itemsFuture = fireservice.getFilteredItems(widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: notifier.background,
          title: Text(widget.categoryName),
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
        body: Center(
          child: FutureBuilder<List<ShopItemModel>>(
            future: itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No results found"),
                );
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 0.8,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ShopItemTIledSmall(
                    email: snapshot.data![index].email,
                    images: snapshot.data![index].images,
                    dateAdded: snapshot.data![index].dateAdded,
                    title: snapshot.data![index].title,
                    sellerName: snapshot.data![index].sellerName,
                    price: snapshot.data![index].price,
                    status: snapshot.data![index].status,
                    address: snapshot.data![index].address,
                    description: snapshot.data![index].description,
                    favoritesCount: snapshot.data![index].favoritesCount,
                    likesCount: snapshot.data![index].likesCount,
                    profileUrl: snapshot.data![index].profileUrl,
                    tags: snapshot.data![index].tags,
                  );
                },
              );
            },
          ),
        ),
      );
    });
  }
}
