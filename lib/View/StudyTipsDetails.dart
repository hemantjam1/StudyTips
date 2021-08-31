import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:studytips/Services/SqlServices.dart';

class StudyTipsDetails extends StatefulWidget {
  final String title;
  final int categoryId;
  final int pageNumber;
  final String isFav;

  const StudyTipsDetails(
      {Key? key,
      required this.title,
      required this.categoryId,
      required this.isFav,
      required this.pageNumber})
      : super(key: key);
  @override
  _StudyTipsDetailsState createState() => _StudyTipsDetailsState();
}

class _StudyTipsDetailsState extends State<StudyTipsDetails> {
  late PageController pageController;
  late int number;
  @override
  void initState() {
    pageController =
        PageController(initialPage: widget.pageNumber, keepPage: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SqlServices>(
      builder: (context, sqlServices, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: FutureBuilder(
            future: sqlServices.queryCategory(catId: widget.categoryId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                List res = snapshot.data as List;
                number = res.length;
                return PageView.builder(
                  controller: pageController,
                  itemCount: res.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          margin: EdgeInsets.all(10),
                          elevation: 05,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('#${index + 1}'.toString(),
                                        textScaleFactor: 1.5),
                                    IconButton(
                                      icon: Icon(res[index]['isFav'] == 'false'
                                          ? Icons.favorite_border
                                          : Icons.favorite),
                                      color: Colors.red,
                                      iconSize: 30,
                                      onPressed: () {
                                        if (res[index]['isFav'] == 'true') {
                                          sqlServices.addToFavorite(
                                              catId: res[index]['categoryId'],
                                              isFav: 'false',
                                              studyTipsId: res[index]
                                                  ['studyTipsId']);
                                        } else {
                                          sqlServices.addToFavorite(
                                            catId: res[index]['categoryId'],
                                            isFav: 'true',
                                            studyTipsId: res[index]
                                                ['studyTipsId'],
                                          );
                                        }
                                      },
                                    )
                                  ],
                                ),
                                SizedBox(height: 20),
                                Text(res[index]['studyTip'].toString())
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          bottomNavigationBar: Consumer<SqlServices>(
            builder: (context, sqlServices, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  sqlServices.showBannerAd(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.loop),
                        onPressed: () {
                          pageController.animateToPage(Random().nextInt(number),
                              duration: Duration(milliseconds: 1),
                              curve: Curves.ease);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          sqlServices
                              .singleStudyTips(
                                  studyTipsId: pageController.page!.ceil(),
                                  catId: widget.categoryId)
                              .then(
                            (value) {
                              Clipboard.setData(ClipboardData(text: value));
                              Fluttertoast.showToast(
                                  msg: 'copied to clipboard');
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () async {
                          sqlServices
                              .singleStudyTips(
                                  studyTipsId: pageController.page!.ceil(),
                                  catId: widget.categoryId)
                              .then(
                            (value) {
                              print('this is returnd value $value');
                              Share.share(value);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
