import 'package:art_app/components/page_notifier.dart';
import 'package:art_app/components/shop_item.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/models/shop_item_model.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  final fireservice = FirestoreService();
  int fetchedItems = 0;
  List<ShopItemModel> items = [];
  List<ShopItemModel> savedItems = [];

  @override
  void initState() {
    super.initState();
    fireservice.getFilteredSearchItems('', (result) {
      if (result.isNotEmpty) {
        setState(() {
          savedItems = result;
        });
      }
    });
  }

  FocusNode searchFocusNode = FocusNode();

  void pageRefresh() async {
    if (Provider.of<PageChangeNotifier>(context, listen: false).shouldRefresh) {
      setState(() {
        savedItems = [];
      });
      savedItems = [];
      fireservice.getFilteredSearchItems('', (result) {
        if (result.isNotEmpty) {
          setState(() {
            savedItems = result;
          });
        }
      });
    }
    setState(() {
      searchFocusNode.unfocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isListening = false;
  final Modals _bottomModal = Modals();

  void handleSearch(String text) {
    if (text.isNotEmpty) {
      List<ShopItemModel> filteredItems = savedItems
          .where((item) =>
              item.title.toLowerCase().contains(text.toLowerCase()) ||
              item.sellerName.toLowerCase().contains(text.toLowerCase()) ||
              item.tags
                  .any((tag) => tag.toLowerCase().contains(text.toLowerCase())))
          .toList();

      setState(() {
        items = filteredItems;
      });
    } else {
      setState(() {
        items = [];
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    focusNode: searchFocusNode,
                    controller: searchController,
                    onChanged: (index) {
                      if (index.isNotEmpty) {
                        handleSearch(index);
                      } else {
                        setState(() {});
                      }
                    },
                    onSubmitted: (index) {
                      handleSearch(index);
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () async {
                          initializeSpeech();
                        },
                        icon: Icon(
                            isListening ? Icons.mic_none : Icons.mic_rounded,
                            color: notifier.primary),
                      ),
                      hintText: 'Search...',
                      fillColor: Colors.grey[50],
                      hintStyle: TextStyle(color: notifier.onSurface),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    fireservice.getFilteredSearchItems(searchController.text,
                        (result) {
                      if (result.isNotEmpty) {
                        setState(() {
                          items = result;
                        });
                      }
                    });
                  },
                  child: const Text('Search'),
                )
              ],
            ),
          ),
          body: searchController.text.isEmpty && savedItems.isNotEmpty
              ? displayGrid(savedItems)
              : displayGrid(items));
    });
  }

  void initializeSpeech() async {
    await _speech.initialize();
    if (_speech.isAvailable) {
      if (!_speech.isListening) {
        try {
          // ignore: use_build_context_synchronously
          await _bottomModal.loaderResponse(context, 'Listening...');
          await _speech.listen(
            onResult: (result) {
              setState(() {
                searchController.text = result.recognizedWords;
                _bottomModal.closeModal();
              });
            },
          );
          setState(() {
            isListening = true;
          });
        } catch (e) {
          debugPrint(e.toString());
        }
      } else {
        _speech.stop();
        setState(() {
          isListening = false;
        });
      }
    }
  }

  Widget displayGrid(List<ShopItemModel> item) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: .5,
      ),
      itemCount: item.length,
      itemBuilder: (context, index) {
        return ShopItemTIledSmall(
          email: item[index].email,
          images: item[index].images,
          dateAdded: item[index].dateAdded,
          title: item[index].title,
          sellerName: item[index].sellerName,
          price: item[index].price,
          status: item[index].status,
          address: item[index].address,
          description: item[index].description,
          favoritesCount: item[index].favoritesCount,
          likesCount: item[index].likesCount,
          profileUrl: item[index].profileUrl,
          tags: item[index].tags,
        );
      },
    );
  }
}
