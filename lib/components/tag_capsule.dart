import 'package:art_app/components/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagDialog extends StatelessWidget {
  final TextEditingController tagController;
  final Function(String) onTagAdded;

  const TagDialog({
    super.key,
    required this.tagController,
    required this.onTagAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return GestureDetector(
        onTap: () async {
          String? addedTag = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                surfaceTintColor: notifier.surface,
                title: const Text('Enter tag'),
                content: TextField(
                  controller: tagController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Color.fromARGB(255, 18, 18, 18)),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      String newTag = tagController.text.trim();
                      if (newTag.isNotEmpty) {
                        Navigator.of(context).pop(newTag);
                      }
                    },
                  ),
                ],
              );
            },
          );

          if (addedTag != null && addedTag.isNotEmpty) {
            onTagAdded(addedTag);
          }
          tagController.clear();
        },
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: const BoxDecoration(),
          child: Icon(Icons.add, color: notifier.primary),
        ),
      );
    });
  }
}

class TagDisplay extends StatelessWidget {
  final List<String> interests;
  final Function(String) onDelete;
  final Function(String) onTagAdded;

  const TagDisplay({
    super.key,
    required this.interests,
    required this.onDelete,
    required this.onTagAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      children: [
        ...interests.map(
          (interest) => GestureDetector(
            onTap: () {
              onDelete(interest);
            },
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                interest,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        TagDialog(
          tagController: TextEditingController(),
          onTagAdded: (String addedTag) {
            onTagAdded(addedTag);
          },
        ),
      ],
    );
  }
}
