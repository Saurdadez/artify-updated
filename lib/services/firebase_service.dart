import 'dart:core';
import 'dart:io';

import 'package:art_app/models/shop_item_model.dart';
import 'package:art_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:art_app/models/book_model.dart';

class FirestoreService {
  final auth = FirebaseAuth.instance;
  final userCollection = FirebaseFirestore.instance.collection('Users');
  final categoriesCollection =
      FirebaseFirestore.instance.collection('Category');
  final shopItemCollection = FirebaseFirestore.instance.collection('ShopItems');
  String? currentUserEmail;
  final cartCollection = FirebaseFirestore.instance.collection('Cart');
  final CollectionReference commissions =
      FirebaseFirestore.instance.collection('Commissions');

  FirestoreService() {
    auth.authStateChanges().listen((user) {
      if (user == null) {
        currentUserEmail = null;
      } else {
        currentUserEmail = user.email;
      }
    });
  }
  //----------------------------------------------------------------
  //STREAMS

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCart() {
    return cartCollection
        .where('userId', isEqualTo: currentUserEmail)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUser(String email) {
    return userCollection.where('email', isEqualTo: email).snapshots();
  }

  Stream<String> getUserProfileUrl(String email) {
    return FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        return userData['profileurl'] as String? ?? '';
      }
      return '';
    });
  }

  Future<void> addBookCommission(BookCommissionModel bookCommission) async {
    try {
      return commissions.add({
        'firstName': bookCommission.firstName,
        'lastName': bookCommission.lastName,
        'email': bookCommission.email,
        'commissioner': bookCommission.commissioner,
        'zipCode': bookCommission.zipCode,
        'contactNumber': bookCommission.contactNumber,
        'city': bookCommission.city,
        'artReference': bookCommission.artReference,
        'address': bookCommission.address,
        'descriptionRequest': bookCommission.descriptionRequest,
      }).then((doc) async {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: bookCommission.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          final commission = List<String>.from(userDoc['commissions'] ?? []);

          commission.add(doc.id);
          await userDoc.reference.update({'commissions': commission});
        } else {
          return null;
        }
        //getUserCollection
      });
    } catch (e) {
      debugPrint('Error adding book commission: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> fetchCommissions() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      final userDocs = await userCollection
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      final userDoc = userDocs.docs.first;

      final commissionsData = userDoc['commissions'];

      if (commissionsData != null && commissionsData is List<dynamic>) {
        final List<String> commissionsList =
            commissionsData.map((item) => item.toString()).toList();

        if (commissionsList.isNotEmpty) {
          final commissionCollection =
              FirebaseFirestore.instance.collection('Commissions');

          final commissionsQuery = await commissionCollection
              .where(FieldPath.documentId, whereIn: commissionsList)
              .get();

          return commissionsQuery.docs.map((doc) => doc.data()).toList();
        }
      }
    }

    return null;
  }

  Future<List> getBookCommission(BookCommissionModel bookCommission) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('commissions').get();

      List<BookCommissionModel> bookCommissions = [];

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        //BookCommissionModel bookCommission = BookCommissionModel.fromMap(data);

        bookCommissions.add(bookCommission);
      }

      return bookCommissions;
    } catch (e) {
      print('Error fetching book commissions: $e');
      return [];
    }
  }

  Future<void> addToFavs(String FavsEmail, String title) async {
    final shopItemCollection =
        FirebaseFirestore.instance.collection('ShopItems');
    final userCollection = FirebaseFirestore.instance.collection('Users');
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    try {
      final shopItemSnapshot = await shopItemCollection
          .where('userId', isEqualTo: FavsEmail)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();
      final userSnapshot = await userCollection
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      final itemDoc = shopItemSnapshot.docs.first;
      final userDoc = userSnapshot.docs.first;
      final favsList = List<String>.from(itemDoc['favorites'] ?? []);
      final userfavsList = List<String>.from(userDoc['userFavorites'] ?? []);
      if (!favsList.contains(currentUserEmail)) {
        favsList.add(currentUserEmail ?? '');

        await itemDoc.reference.update({'favorites': favsList});
      }
      if (!userfavsList.contains(itemDoc.id)) {
        userfavsList.add(itemDoc.id);

        await userDoc.reference.update({'userFavorites': userfavsList});
      }
    } catch (e) {
      debugPrint('Error adding favorites: $e');
    }
  }

  Future<void> removeFromFavs(String favsEmail, String title) async {
    final shopItemCollection =
        FirebaseFirestore.instance.collection('ShopItems');
    final userCollection = FirebaseFirestore.instance.collection('Users');
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    try {
      final shopItemSnapshot = await shopItemCollection
          .where('userId', isEqualTo: favsEmail)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      final itemDoc = shopItemSnapshot.docs.first;
      final itemDocId = itemDoc.id;
      final userSnapshot = await userCollection
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      final userDoc = userSnapshot.docs.first;

      final userfavsList = List<String>.from(userDoc['userFavorites'] ?? []);

      userfavsList.remove(itemDocId);

      await userDoc.reference.update({'userFavorites': userfavsList});

      final itemDocfavsList = List<String>.from(itemDoc['favorites'] ?? []);

      itemDocfavsList.remove(currentUserEmail);

      await itemDoc.reference.update({'favorites': itemDocfavsList});
    } catch (e) {
      debugPrint('Error removing favorites: $e');
    }
  }

  Stream<bool> checkIfInLikes(String email, String title) {
    return shopItemCollection
        .where('userId', isEqualTo: email)
        .where('title', isEqualTo: title)
        .snapshots()
        .asyncMap((shopItemSnapshot) {
      if (shopItemSnapshot.docs.isNotEmpty) {
        final shopItemDoc = shopItemSnapshot.docs.first;
        final likesList = List<String>.from(shopItemDoc['likes'] ?? []);
        return likesList.contains(currentUserEmail);
      }
      return false;
    });
  }

  Stream<QuerySnapshot> getUserCollection() {
    final collection =
        shopItemCollection.orderBy('timestamp', descending: true).snapshots();
    return collection;
  }

  Stream<bool> checkIfInFavorites(String email, String title) {
    final currentUserId = FirebaseAuth.instance.currentUser?.email;
    final shopItemsCollection =
        FirebaseFirestore.instance.collection('ShopItems');

    return shopItemsCollection
        .where('userId', isEqualTo: email)
        .where('title', isEqualTo: title)
        .snapshots()
        .asyncMap((shopItemSnapshot) {
      if (shopItemSnapshot.docs.isNotEmpty) {
        final shopItemDoc = shopItemSnapshot.docs.first;
        final favoritesList = List<String>.from(shopItemDoc['favorites'] ?? []);
        return favoritesList.contains(currentUserId);
      }
      return false;
    });
  }

  Stream<bool> checkIfInCart(String email, String title) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return cartCollection
        .where('userId', isEqualTo: currentUserEmail)
        .snapshots()
        .asyncMap((cartSnapshot) async {
      if (cartSnapshot.docs.isNotEmpty) {
        final userDoc = cartSnapshot.docs.first;

        final shopCollection =
            FirebaseFirestore.instance.collection('ShopItems');
        final shopItemSnapshot = await shopCollection
            .where('userId', isEqualTo: email)
            .where('title', isEqualTo: title)
            .limit(1)
            .get();

        final shopItemDoc = shopItemSnapshot.docs.isNotEmpty
            ? shopItemSnapshot.docs.first.id
            : null;

        if (shopItemDoc != null) {
          final userCartItems = (userDoc.data()['items'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          final shopItemId = shopItemDoc.toString();
          return userCartItems.contains(shopItemId);
        }
      }
      return false;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamShopItemsOfUser(
      String email) {
    return shopItemCollection.where('userId', isEqualTo: email).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAvailableShopItemsOfUser(
      String email) {
    return shopItemCollection
        .where('userId', isEqualTo: email)
        .where('status', isEqualTo: 'Available')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSoldShopItemsOfUser(
      String email) {
    return shopItemCollection
        .where('userId', isEqualTo: email)
        .where('status', isEqualTo: 'Sold')
        .snapshots();
  }

  Stream<List<String>> getUserLikesStream() {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    return FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: currentUserEmail)
        .limit(1)
        .snapshots()
        .map<List<String>>((snapshot) {
      final List<dynamic>? userLikes =
          snapshot.docs.isNotEmpty ? snapshot.docs.first.get('userLiked') : [];
      return userLikes?.cast<String>() ?? [];
    });
  }

  Stream<int> getFollowerCountForUser(String userEmail) {
    return FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: userEmail)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final followers = snapshot.docs.first['followers'];
        return followers.length;
      } else {
        return 0;
      }
    });
  }

  Stream<bool> isFollowingUser(String sellerEmail) {
    return userCollection
        .where('email', isEqualTo: sellerEmail)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final List<dynamic>? followers = snapshot.docs.first['followers'];

        if (followers != null && currentUserEmail != null) {
          return followers.contains(currentUserEmail);
        }
      }
      return false;
    });
  }
//----------------------------------------------------------------

  Future<List<ShopItemModel>> fetchAllItemsWithFilter(
      String filter, List<ShopItemModel> items, int fetchedItems) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = filter.isEmpty
          ? await FirebaseFirestore.instance
              .collection('ShopItems')
              .where('userId', isNotEqualTo: currentUserEmail)
              .limit(10)
              .get()
          : await FirebaseFirestore.instance
              .collection('ShopItems')
              .where('userId', isNotEqualTo: currentUserEmail)
              .where('title', isEqualTo: filter)
              .limit(10)
              .get();

      List<ShopItemModel> shopItems = [];
      for (var doc in querySnapshot.docs) {
        shopItems.add(await addToShopModel(doc));
      }
      return shopItems;
    } catch (e) {
      return [];
    }
  }

  Future<void> createUser(UserObject user) {
    return userCollection.add({
      'dateCreated': user.dateCreated,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'profileurl': user.profileUrl,
      'userLiked': user.userLiked,
      'cityAddress': user.cityAddress,
      'userFavorites': user.userFavorites,
      'followers': user.followers,
      'following': user.following,
      'email': user.email,
      'username': user.username,
      'interests': user.interests,
      'commissions': user.commissions,
      'contactNumber': user.contactNumber,
      'streetAddress': user.streetAddress,
      'zip': user.zip,
      'country': user.country,
      'credits': user.credits,
    });
  }

  Future<Map<String, dynamic>?> getUserInfo(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  Future<void> addFollower(String userEmail) async {
    try {
      final querySnapshot = await userCollection
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();
      final userDoc = querySnapshot.docs.first;

      final currentFollowers = (userDoc.data()['followers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      currentFollowers.add(currentUserEmail ?? '');

      await userDoc.reference.update({'followers': currentFollowers});
    } catch (e) {
      debugPrint('Error adding follower: $e');
    }
  }

  Future<void> deleteFollower(String userEmail) async {
    try {
      final querySnapshot = await userCollection
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();
      final userDoc = querySnapshot.docs.first;

      final currentFollowers = (userDoc.data()['followers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      currentFollowers.remove(currentUserEmail);

      await userDoc.reference.update({'followers': currentFollowers});
    } catch (e) {
      debugPrint('Error deleting follower: $e');
    }
  }

  Future<void> removeFromLikes(String likedEmail, String title) async {
    try {
      final shopItemSnapshot = await shopItemCollection
          .where('userId', isEqualTo: likedEmail)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      final itemDoc = shopItemSnapshot.docs.first;
      final itemDocId = itemDoc.id; // Get the ID of the shop item

      final userSnapshot = await userCollection
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      final userDoc = userSnapshot.docs.first;

      final userlikesList = List<String>.from(userDoc['userLiked'] ?? []);

      userlikesList.remove(itemDocId);

      await userDoc.reference.update({'userLiked': userlikesList});

      final itemDoclikesList = List<String>.from(itemDoc['likes'] ?? []);

      itemDoclikesList.remove(currentUserEmail);

      await itemDoc.reference.update({'likes': itemDoclikesList});
    } catch (e) {
      debugPrint('Error removing likes: $e');
    }
  }

  Future<void> addToLikes(String likedEmail, String title) async {
    try {
      final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
      final shopItemSnapshot = await shopItemCollection
          .where('userId', isEqualTo: likedEmail)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();
      final userSnapshot = await userCollection
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      final itemDoc = shopItemSnapshot.docs.first;
      final userDoc = userSnapshot.docs.first;
      final likesList = List<String>.from(itemDoc['likes'] ?? []);
      final userlikesList = List<String>.from(userDoc['userLiked'] ?? []);
      if (!likesList.contains(currentUserEmail)) {
        likesList.add(currentUserEmail ?? '');

        await itemDoc.reference.update({'likes': likesList});
      }
      if (!userlikesList.contains(itemDoc.id)) {
        userlikesList.add(itemDoc.id);

        await userDoc.reference.update({'userLiked': userlikesList});
      }
    } catch (e) {
      debugPrint('Error adding likes: $e');
    }
  }

  Future<void> removeFromFavorites(String likedEmail, String title) async {
    try {
      final shopItemSnapshot = await shopItemCollection
          .where('userId', isEqualTo: likedEmail)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      final userDoc = shopItemSnapshot.docs.first;

      final favoritesList = List<String>.from(userDoc['favorites'] ?? []);

      favoritesList.remove(currentUserEmail);

      await userDoc.reference.update({'favorites': favoritesList});
    } catch (e) {
      debugPrint('Error removing favorites: $e');
    }
  }

  Future<void> addToFavorites(String likedEmail, String title) async {
    try {
      final shopItemSnapshot = await shopItemCollection
          .where('userId', isEqualTo: likedEmail)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      final userDoc = shopItemSnapshot.docs.first;

      final favoritesList = List<String>.from(userDoc['favorites'] ?? []);

      if (!favoritesList.contains(currentUserEmail)) {
        favoritesList.add(currentUserEmail ?? '');

        await userDoc.reference.update({'favorites': favoritesList});
      }
    } catch (e) {
      debugPrint('Error adding favorites: $e');
    }
  }

  Future<void> addToCart(String userId, String title) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.email;
    final cartCollection = FirebaseFirestore.instance.collection('Cart');

    final cartQuery =
        cartCollection.where('userId', isEqualTo: currentUserId).limit(1);
    final cartSnapshot = await cartQuery.get();

    if (cartSnapshot.docs.isNotEmpty) {
      final userDoc = cartSnapshot.docs.first;

      final shopCollection = FirebaseFirestore.instance.collection('ShopItems');
      final shopItemSnapshot = await shopCollection
          .where('userId', isEqualTo: userId)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      final shopItemDoc = shopItemSnapshot.docs.isNotEmpty
          ? shopItemSnapshot.docs.first.reference.id
          : null;

      if (shopItemDoc != null) {
        final userCartItems = (userDoc.data()['items'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        userCartItems.add(shopItemDoc);

        await userDoc.reference.update({'items': userCartItems});
      }
    } else {
      final newCartData = {'userId': currentUserId, 'items': []};

      final newCartRef = await cartCollection.add(newCartData);

      final shopCollection = FirebaseFirestore.instance.collection('ShopItems');
      final shopItemSnapshot = await shopCollection
          .where('userId', isEqualTo: userId)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      final shopItemDoc = shopItemSnapshot.docs.isNotEmpty
          ? shopItemSnapshot.docs.first.reference.id
          : null;

      if (shopItemDoc != null) {
        final userCartItems = [shopItemDoc];
        await newCartRef.update({'items': userCartItems});
      }
    }
  }

  Future<void> removeFromCart(String userId, String title) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    final cartQuery =
        cartCollection.where('userId', isEqualTo: currentUserEmail).limit(1);
    final cartSnapshot = await cartQuery.get();
    debugPrint(currentUserEmail);
    if (cartSnapshot.docs.isNotEmpty) {
      final userDoc = cartSnapshot.docs.first;

      final shopItemSnapshot = await shopItemCollection
          .where('userId', isEqualTo: userId)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      final shopItemDoc = shopItemSnapshot.docs.isNotEmpty
          ? shopItemSnapshot.docs.first.reference.id
          : null;

      if (shopItemDoc != null) {
        final userCartItems = (userDoc.data()['items'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        userCartItems.remove(shopItemDoc);

        await userDoc.reference.update({'items': userCartItems});
      }
    } else {
      debugPrint('User cart not found.');
    }
  }

  Future<void> addShopItem(PostShopITem item) async {
    try {
      await shopItemCollection.add(item.toMap());
    } catch (e) {
      debugPrint('Error adding shop item: $e');
    }
  }

  Future<String> uploadImageToFirebase(
      String imagePath, String parentFolder) async {
    if (imagePath.isNotEmpty) {
      final imageFile = File(imagePath);
      DateTime now = DateTime.now();
      String timestamp = now.microsecondsSinceEpoch.toString();
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageReference =
          storage.ref().child(parentFolder).child('image_$timestamp.jpg');

      UploadTask uploadTask = storageReference.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    }
    return 'N/A';
  }

  Future<void> markOrderSold(String title, String userId) async {
    try {
      final querySnapshot = await shopItemCollection
          .where('userId', isEqualTo: userId)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final itemDoc = querySnapshot.docs.first;
        await itemDoc.reference.update({'status': 'Sold'});
        debugPrint('Order marked as Sold');
      } else {
        debugPrint('No matching documents found');
      }
    } catch (e) {
      debugPrint('Error marking order as Sold: $e');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> userUpdate,
      Map<String, dynamic>? fetchedProfile) async {
    final user = await userCollection
        .where('email', isEqualTo: userUpdate['email'])
        .get();
    bool checkField(Map<String, dynamic> userUpdate,
        Map<String, dynamic>? fetchedProfile, String field) {
      return userUpdate[field].isNotEmpty &&
          fetchedProfile?[field] != userUpdate[field].isNotEmpty &&
          userUpdate[field] != 'N/A';
    }

    final userDocRef = user.docs.first;
    if (checkField(userUpdate, fetchedProfile, 'username')) {
      userDocRef.reference.update({'username': userUpdate['username']});
    }
    if (checkField(userUpdate, fetchedProfile, 'country')) {
      userDocRef.reference.update({'country': userUpdate['country']});
    }
    if (checkField(userUpdate, fetchedProfile, 'firstName')) {
      userDocRef.reference.update({'firstName': userUpdate['firstName']});
    }

    if (checkField(userUpdate, fetchedProfile, 'lastName')) {
      userDocRef.reference.update({'lastName': userUpdate['lastName']});
    }
    if (checkField(userUpdate, fetchedProfile, 'contactNumber')) {
      userDocRef.reference
          .update({'contactNumber': userUpdate['contactNumber']});
    }
    if (checkField(userUpdate, fetchedProfile, 'streetAddress')) {
      userDocRef.reference
          .update({'streetAddress': userUpdate['streetAddress']});
    }
    if (checkField(userUpdate, fetchedProfile, 'cityAddress')) {
      userDocRef.reference.update({'cityAddress': userUpdate['cityAddress']});
    }
    if (checkField(userUpdate, fetchedProfile, 'zip')) {
      userDocRef.reference.update({'zip': userUpdate['zip']});
    }
    if (checkField(userUpdate, fetchedProfile, 'email')) {
      userDocRef.reference.update({'email': userUpdate['email']});
    }
    userDocRef.reference.update({'profileurl': userUpdate['profileurl']});
  }

  Future<void> removeImageFromStorage(String url) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference imageref = storage.refFromURL(url);

    try {
      await imageref.delete();
      debugPrint('Image deleted from storage');
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<List<ShopItemModel>> fetchShopItems(
      Function(List<ShopItemModel>) onDataReceived) async {
    try {
      final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('ShopItems')
              .where('status', isEqualTo: 'Available')
              .where('userId', isNotEqualTo: currentUserEmail)
              .get();

      List<DocumentSnapshot<Map<String, dynamic>>> shuffledDocs =
          List.from(querySnapshot.docs)..shuffle();
      List<ShopItemModel> shopItems = [];
      int count = 0;
      for (var doc in shuffledDocs) {
        count++;

        shopItems.add(await addToShopModel(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>));

        if (count == 2) {
          onDataReceived(shopItems);
        } else if (count > 2) {
          onDataReceived(shopItems);
        }
      }
      return shopItems;
    } catch (e) {
      debugPrint('Error fetching shop items: $e');
      return [];
    }
  }

  Future<List<ShopItemModel>> getFilteredItems(String filter) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('ShopItems')
        .where('status', isEqualTo: 'Available')
        .where('userId', isNotEqualTo: currentUserEmail)
        .get();

    final shopItems = querySnapshot.docs.where((doc) {
      List<String> tags = List<String>.from(doc['tags'] ?? []);
      return tags
          .any((tag) => tag.toLowerCase().contains(filter.toLowerCase()));
    }).map((doc) async {
      String? profile = await FirestoreService().getProfileUrl(doc['userId']);
      var userinfo = await FirestoreService().getUserInfo(doc['userId']);

      return ShopItemModel(
        address: doc['location'],
        dateAdded: doc['dateAdded'],
        username: userinfo?['username'],
        description: doc['description'],
        favoritesCount: (doc['favorites'] as List<dynamic>).length,
        images: doc['images'] != null ? List<String>.from(doc['images']) : [],
        likesCount: (doc['likes'] as List<dynamic>).length,
        price: (doc['price'] as double).toInt(),
        profileUrl: profile!,
        sellerName: doc['artist'],
        status: doc['status'],
        tags: List<String>.from(doc['tags'] ?? []),
        title: doc['title'],
        email: doc['userId'],
      );
    }).toList();

    return Future.wait(shopItems);
  }

  Future<ShopItemModel> addToShopModel(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    String? profile = await FirestoreService().getProfileUrl(doc['userId']);
    var userinfo = await FirestoreService().getUserInfo(doc['userId']);
    return ShopItemModel(
      address: doc['location'],
      dateAdded: doc['dateAdded'],
      username: userinfo?['username'],
      description: doc['description'],
      favoritesCount: (doc['favorites'] as List<dynamic>).length,
      images: doc['images'] != null ? List<String>.from(doc['images']) : [],
      likesCount: (doc['likes'] as List<dynamic>).length,
      price: (doc['price']).toInt(),
      profileUrl: profile!,
      sellerName: '${userinfo?['firstName']} ${userinfo?['lastName']}',
      status: doc['status'],
      tags: List<String>.from(doc['tags'] ?? []),
      title: doc['title'],
      email: doc['userId'],
    );
  }

  Future<List<ShopItemModel>> getArtistPicks() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await shopItemCollection.get();

      List<ShopItemModel> shopItems = [];
      for (var doc in querySnapshot.docs) {
        List<dynamic> likes = doc['likes'] ?? [];
        int likesCount = likes.length;

        if (likesCount > 1) {
          shopItems.add(await addToShopModel(doc));
        }
      }
      return shopItems;
    } catch (e) {
      debugPrint('Error fetching artist picks: $e');
      return [];
    }
  }

  Future<void> updateShopItem({
    required String userId,
    required String title,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final shopItemsCollection =
          FirebaseFirestore.instance.collection('ShopItems');
      final querySnapshot = await shopItemsCollection
          .where('userId', isEqualTo: userId)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final shopItemDoc = querySnapshot.docs.first.reference;
        await shopItemDoc.update(updateData);
        debugPrint('Shop item updated successfully');
      } else {
        debugPrint('No matching documents found for updating shop item');
      }
    } catch (e) {
      debugPrint('Error updating shop item: $e');
    }
  }

  Future<List<Map<String, dynamic>?>> getTopArtists() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await userCollection.get();

      List<Map<String, dynamic>?> topartists = [];
      for (var doc in querySnapshot.docs) {
        List<dynamic> followers = doc['followers'] ?? [];
        int followersCount = followers.length;

        if (followersCount > 1) {
          topartists.add(await getUserInfo(doc['email']));
        }
      }
      return topartists;
    } catch (e) {
      debugPrint('Error fetching top artist: $e');
      return [];
    }
  }

  Future<bool> deleteShopItem(String title) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    QuerySnapshot querySnapshot = await shopItemCollection
        .where('userId', isEqualTo: currentUserEmail)
        .where('title', isEqualTo: title)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final item = querySnapshot.docs.first;
      final data = item.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('images')) {
        List<dynamic> images = data['images'];

        for (var imageUrl in images) {
          await removeImageFromStorage(imageUrl.toString());
        }

        await item.reference.delete();
        return true;
      }
    }
    return false;
  }

  Future<bool> doesUserExist(String email) async {
    final QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
        .instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<String?> getProfileUrl(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        return userData['profileurl'] as String?;
      }
    } catch (e) {
      debugPrint('Error fetching profile URL: $e');
    }
    return null;
  }

  static Future<bool> isUsernameAvailable(String username) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('Users')
        .where('username', isEqualTo: username)
        .get();
    return query.docs.isEmpty;
  }

  Stream<QuerySnapshot<Object?>> getCategories() {
    final fetchedCategories = categoriesCollection.snapshots();
    return fetchedCategories;
  }

  Future<List<String>> getCategoriesAsList() async {
    final snapshot = await categoriesCollection.get();
    List<String> categoryList = [];
    for (var doc in snapshot.docs) {
      List<dynamic>? categories = doc.get('category');
      if (categories != null) {
        categoryList.addAll(categories.map((category) => category.toString()));
      }
    }
    return categoryList;
  }

  Future<List<ShopItemModel>> getFilteredSearchItems(
    String filter,
    Function(List<ShopItemModel>) onDataReceived,
  ) async {
    try {
      final querySnapshot = await shopItemCollection
          .where('userId', isNotEqualTo: currentUserEmail)
          .where('status', isEqualTo: 'Available')
          .get();
      List<ShopItemModel> shopItems = [];

      if (filter.isEmpty) {
        for (var doc in querySnapshot.docs) {
          shopItems.add(await addToShopModel(doc));
          onDataReceived(shopItems);
        }
      } else {
        for (var doc in querySnapshot.docs) {
          String title = doc['title'].toString();
          String firstName = doc['artist'].toString();
          List<String> tags = List<String>.from(doc['tags'] ?? []);

          if ((title.toLowerCase().contains(filter.toLowerCase()) ||
              firstName.toLowerCase().contains(filter.toLowerCase()) ||
              tags.any(
                  (tag) => tag.toLowerCase().contains(filter.toLowerCase())))) {
            shopItems.add(await addToShopModel(doc));
            onDataReceived(shopItems);
          }
        }
      }
      return shopItems;
    } catch (e) {
      return [];
    }
  }
}
