import 'package:flutter/material.dart';

class ItemDetail extends StatelessWidget {
  const ItemDetail({super.key, required this.value, required this.text});

  final dynamic value;
  final String text;

  @override
  Widget build(BuildContext context) {
    var halfscreen = MediaQuery.of(context).size.width / 2;
    return Row(
      children: [
        SizedBox(
            width: halfscreen,
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400]),
            )),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
