import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:studytips/Services/SqlServices.dart';

class Favorite extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'),
      ),
      body: Consumer<SqlServices>(
        builder: (context, sqlServices, child) {
          return FutureBuilder(
            future: sqlServices.queryFavorite(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                List res = snapshot.data as List;
                return Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: res.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 10),
                      child: ListTile(
                        title: Text(
                          res[index]['studyTip'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        leading: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.purple,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(50),
                            ),
                          ),
                          child: Center(
                            child: Text((index + 1).toString()),
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoritesDetails(
                                pageNumber: index, isFav: 'true'),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: SqlServices().showBannerAd(),
    );
  }
}

class FavoritesDetails extends StatefulWidget {
  final int pageNumber;
  final String isFav;

  const FavoritesDetails(
      {Key? key, required this.pageNumber, required this.isFav})
      : super(key: key);

  @override
  _FavoritesDetailsState createState() => _FavoritesDetailsState();
}

class _FavoritesDetailsState extends State<FavoritesDetails> {
  late PageController pageController;

  @override
  void initState() {
    pageController =
        PageController(initialPage: widget.pageNumber, keepPage: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isF = widget.isFav == 'true';
    int _index = widget.pageNumber;
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: Consumer<SqlServices>(
        builder: (context, sqlServices, child) {
          return FutureBuilder(
            future: sqlServices.queryFavorite(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Your Favorites will be listed here'),
                    ),
                  ),
                );
              } else {
                List res = snapshot.data as List;
                int number = res.length;
                return Column(
                  children: [
                    Flexible(
                      child: PageView.builder(
                        itemCount: res.length,
                        controller: pageController,
                        itemBuilder: (context, index) {
                          _index = index;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Card(
                                margin: EdgeInsets.all(10),
                                elevation: 05,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('#${index + 1}'.toString(),
                                              textScaleFactor: 1.5),
                                          IconButton(
                                            icon: Icon(
                                                res[index]['isFav'] == 'false'
                                                    ? Icons.favorite
                                                    : Icons.favorite),
                                            color: Colors.red,
                                            iconSize: 30,
                                            onPressed: () {
                                              isF = !isF;
                                              sqlServices
                                                  .addToFavorite(
                                                      catId: res[index]
                                                          ['categoryId'],
                                                      isFav: isF.toString(),
                                                      studyTipsId: res[index]
                                                          ['studyTipsId'])
                                                  .then(
                                                (value) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Removed from favorite');
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Text(res[index]['studyTip']),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            icon: Icon(Icons.loop),
                            onPressed: () {
                              print(Random().nextInt(number));
                              pageController.animateToPage(
                                  Random().nextInt(number),
                                  duration: Duration(milliseconds: 1),
                                  curve: Curves.ease);
                            }),
                        Consumer<SqlServices>(
                          builder: (context, sqlServices, child) => IconButton(
                            icon: Icon(Icons.copy),
                            onPressed: () {
                              sqlServices
                                  .favoriteCopy(
                                      studyTipsId: res[_index]['studyTipsId'],
                                      catId: res[_index]['categoryId'])
                                  .then(
                                (value) {
                                  Clipboard.setData(ClipboardData(text: value));
                                  Fluttertoast.showToast(
                                      msg: 'copied to clipboard');
                                },
                              );
                            },
                          ),
                        ),
                        Consumer<SqlServices>(
                          builder: (context, sqlServices, child) => IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () async {
                              sqlServices
                                  .favoriteCopy(
                                      studyTipsId: res[_index]['studyTipsId'],
                                      catId: res[_index]['categoryId'])
                                  .then(
                                (value) {
                                  Share.share(value);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: SqlServices().showBannerAd(),
    );
  }
}
