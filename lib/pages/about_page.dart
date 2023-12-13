// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Page'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://i.pinimg.com/564x/9e/9e/29/9e9e29f7a9695072d44b0b1100829c95.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Artify.',
                        style: TextStyle(
                          fontSize: 35.0,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 20.0),
                  Center(
                    child: Container(
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://i.pinimg.com/564x/ae/d8/77/aed877501d31fc81e20e7992263bcce7.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'The art inspired by your story',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                ],
              ),
              SizedBox(height: 80.0),
              Row(
                children: [
                  Center(
                    child: Container(
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://i.pinimg.com/originals/f1/e1/39/f1e13922f700ec3a41e469f7412416ba.gif',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vision',
                              style: TextStyle(
                                fontSize: 25.0,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'A platform designed to empower emerging artists by providing a space to showcase their work.',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                ],
              ),
              SizedBox(height: 80.0),
              Row(
                children: [
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mission:',
                            style: TextStyle(
                              fontSize: 25.0,
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Cultivate a supportive \nenvironment for both \ncreators and appreciators\n of art, fostering a vibrant \nand thriving \ncommunity within the app.',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 200.0,
                        height: 200.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://i.pinimg.com/originals/65/c5/d9/65c5d9039889e9efe9a75cf8ec873562.gif',
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 90.0),
              Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.facebook,
                              size: 30.0, color: Colors.blue),
                          onPressed: () {
                            _launchURL(
                                'https://www.facebook.com/kylle.mendoza89/');
                          },
                        ),
                        SizedBox(width: 20.0),
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.envelope,
                              size: 30.0, color: Colors.red),
                          onPressed: () {
                            _launchURL(
                                'https://youtu.be/dQw4w9WgXcQ?feature=shared');
                          },
                        ),
                        SizedBox(width: 20.0),
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.instagram,
                              size: 30.0, color: Colors.purple),
                          onPressed: () {
                            _launchURL(
                                'https://youtu.be/dQw4w9WgXcQ?feature=shared');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
