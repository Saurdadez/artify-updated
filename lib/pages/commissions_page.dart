import 'package:art_app/services/firebase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CommissionsPage extends StatefulWidget {
  const CommissionsPage({Key? key}) : super(key: key);

  @override
  State<CommissionsPage> createState() => _CommissionsPageState();
}

class _CommissionsPageState extends State<CommissionsPage> {
  List<Map<String, dynamic>>? commissionList = [];
  final fireservice = FirestoreService();

  @override
  void initState() {
    super.initState();
    fireservice.fetchCommissions().then((value) {
      setState(() {
        commissionList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commissions'),
      ),
      body: commissionList != null && commissionList!.isNotEmpty
          ? ListView.builder(
              itemCount: commissionList!.length,
              itemBuilder: (context, index) {
                final commission = commissionList![index];
                final title = 'Commission ${index + 1}';
                final description =
                    commission['descriptionRequest'] ?? 'No Description';

                return ListTile(
                  title: Text(title),
                  subtitle: Text(description),
                  trailing: Container(
                    width: 100,
                    height: 50,
                    child: CachedNetworkImage(
                      imageUrl: commission['artReference'][0],
                      fit: BoxFit.cover,
                      width: 100,
                    ),
                  ),
                  onTap: () {},
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
