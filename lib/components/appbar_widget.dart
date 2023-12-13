import 'package:art_app/pages/search_page.dart';
import 'package:flutter/material.dart';

class CustomizedAppbar extends StatefulWidget implements PreferredSizeWidget {
  const CustomizedAppbar({super.key});

  @override
  State<CustomizedAppbar> createState() => _CustomizedAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomizedAppbarState extends State<CustomizedAppbar> {
  bool isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();
  String searchtext = 'Search...';

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        title: Text(
          'artify.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(8),
            width: 150,
            child: TextField(
              focusNode: _searchFocusNode,
              onTap: () async {
                _searchFocusNode.unfocus();
                final searchresult = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPage()));
                if (searchresult != null) {
                  setState(() {
                    searchtext = searchresult;
                  });
                }
              },
              onSubmitted: (value) async {
                _searchFocusNode.unfocus();
                final searchresult = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
                if (searchresult != null) {
                  setState(() {
                    searchtext = searchresult;
                  });
                }
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchFocusNode.unfocus();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchPage()));
                  },
                  icon: const Icon(Icons.search),
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintText: searchtext,
                contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                hintStyle:
                    const TextStyle(color: Color.fromARGB(255, 111, 111, 111)),
                fillColor: const Color.fromARGB(230, 240, 240, 240),
                filled: true,
                enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Color.fromARGB(255, 255, 173, 114)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
