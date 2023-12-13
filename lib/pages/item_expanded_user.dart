import 'package:art_app/components/image_carousel.dart';
import 'package:art_app/components/item_details_widget.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/pages/editpost_page.dart';
import 'package:art_app/services/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UseritemExpanded extends StatefulWidget {
  const UseritemExpanded({
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
  State<UseritemExpanded> createState() => _UseritemExpandedState();
}

class _UseritemExpandedState extends State<UseritemExpanded> {
  var _pageController = PageController();
  var _scrollController = ScrollController();
  var screenheight = 0.0;
  bool isScrollEnabled = false;
  List<ImageProvider> imageProviders = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    preloadImages();
  }

  void preloadImages() {
    for (var imageUrl in widget.images) {
      precacheImage(CachedNetworkImageProvider(imageUrl), context);
      imageProviders.add(CachedNetworkImageProvider(imageUrl));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  int currentImageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        floatingActionButton: Container(
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: notifier.primary),
          child: IconButton(
              icon: Icon(
                Icons.edit,
                color: notifier.onSurface,
              ),
              onPressed: () {
                Modals.expandedModal(
                    context,
                    EditPost(
                      description: widget.description,
                      email: widget.email,
                      price: widget.price,
                      tags: widget.tags,
                      title: widget.title,
                      images: widget.images,
                    ),
                    notifier);
              }),
        ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height / 1.5,
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.black.withOpacity(0.5),
                  child: Text(
                    '${currentImageIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              flexibleSpace: PageView.builder(
                itemCount: widget.images.length,
                controller: _pageController,
                itemBuilder: (context, index) {
                  return ImageCarousel(
                    currentIndex: index,
                    imgProviders: imageProviders,
                  );
                },
                onPageChanged: (value) {
                  setState(() {
                    currentImageIndex = value;
                  });
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 100),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                      Text(widget.sellerName,
                          style: const TextStyle(
                            fontSize: 25,
                          )),
                      const SizedBox(
                        height: 15,
                      ),
                      Wrap(
                        runSpacing: 20,
                        children: [
                          ItemDetail(
                              value: widget.tags.join(', '), text: 'Tags'),
                          ItemDetail(value: widget.price, text: 'Price'),
                          ItemDetail(
                              value: Utils.getTimeDifference(widget.dateAdded),
                              text: 'Price'),
                          ItemDetail(
                              value: widget.address.contains('N/A')
                                  ? 'Not specified'
                                  : widget.address,
                              text: 'Location'),
                        ],
                      ),
                      const Divider(
                        color: Color.fromARGB(255, 64, 64, 64),
                        thickness: 1,
                        height: 50,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          'About the artwork',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                      ),
                      Text(
                        widget.description,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}
