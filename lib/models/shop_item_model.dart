class PostShopITem {
  final String title;
  final String artist;
  final double price;
  final String userId;
  final String dateAdded;
  final String status;
  final String description;
  final List<String> favorites;
  final List<String> likes;
  final List<String> tags;
  final String location;
  final List<String> images;

  PostShopITem({
    required this.title,
    required this.artist,
    required this.price,
    required this.userId,
    required this.dateAdded,
    required this.status,
    required this.description,
    required this.favorites,
    required this.location,
    required this.likes,
    required this.tags,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title, // String
      'location': location,
      'artist': artist, // String
      'price': price, // double
      'userId': userId, // String
      'dateAdded': dateAdded, // String
      'status': status, // String
      'description': description, // String
      'favorites': favorites, // List
      'likes': likes, // List
      'tags': tags, // List
      'images': images, // List
    };
  }
}

class ShopItemModel {
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
  final String username;
  final String address;
  final String dateAdded;

  ShopItemModel({
    required this.title,
    required this.email,
    required this.sellerName,
    required this.username,
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

  factory ShopItemModel.fromMap(Map<String, dynamic> map) {
    return ShopItemModel(
      title: map['title'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      sellerName: map['sellerName'] ?? '',
      description: map['description'] ?? '',
      favoritesCount: map['favoritesCount'] ?? 0,
      likesCount: map['likesCount'] ?? 0,
      profileUrl: map['profileUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      price: map['price'] ?? 0,
      address: map['address'] ?? '',
      status: map['status'] ?? '',
      dateAdded: map['dateAdded'] ?? '',
    );
  }
}
