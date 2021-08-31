import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:studytips/Services/SqlServices.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Favorite.dart';
import 'StudyTipsCategory.dart';
import 'StudyTipsImages.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SqlServices sqlServices = SqlServices();
  bool isConnection = true;
  checkConnectivity() async {
    try {
      final res = await InternetAddress.lookup('google.com');
      if (res.isNotEmpty && res.first.rawAddress.isNotEmpty)
        isConnection = true;
    } on SocketException catch (e) {
      print(e);
      isConnection = false;
    }
  }

  launching() async {
    try {
      await launch('https://www.google.com/');
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    checkConnectivity();
    sqlServices.checkDb().then((bool value) => sqlServices.fetchDb(value));
    super.initState();
    Future.delayed(
      Duration(seconds: 30),
      () {
        SqlServices.interstitialAd.show();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/title.jpg'),
          ),
        ),
        title: Text('Study Tips'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Favorite()));
              },
              icon: Icon(
                Icons.favorite,
                color: Colors.red,
              )),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage("assets/images/title.jpg"),
                      ),
                      Text('  Study Tips')
                    ],
                  ),
                  content: Text(
                      "Check out the best collection of study tips , be successful!"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          launching();
                          // Share.share('https://www.google.com/');
                          Navigator.pop(context);
                        },
                        child: Text('PRIVACY POLICY')),
                    TextButton(
                        onPressed: () {
                          launching();
                          Navigator.pop(context);
                        },
                        child: Text('MORE APPS')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isConnection ? StudyTipsImages() : SizedBox(),
            Flexible(child: StudyTipsCategory()),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     sqlServices.singleStudyTips(studyTipsId: 1, catId: 1);
      //   },
      // ),
    );
  }
}
