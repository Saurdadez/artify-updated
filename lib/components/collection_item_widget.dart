import 'package:art_app/pages/item_expanded_user.dart';
import 'package:art_app/pages/item_expanded.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserShopItemSmall extends StatefulWidget {
  const UserShopItemSmall({
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
  State<UserShopItemSmall> createState() => _UserShopItemSmallState();
}

class _UserShopItemSmallState extends State<UserShopItemSmall> {
  @override
  Widget build(BuildContext context) {
    bool isCurrentUserEmail =
        FirebaseAuth.instance.currentUser?.email == widget.email;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => isCurrentUserEmail
                    ? UseritemExpanded(
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
                      )
                    : ItemExpanded(
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
        child: SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width / 2 - 2,
          child: CachedNetworkImage(
            imageUrl: widget.images[0],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
