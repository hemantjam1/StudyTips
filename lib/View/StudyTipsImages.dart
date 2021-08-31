import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:share/share.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudyTipsImages extends StatefulWidget {
  @override
  _StudyTipsImagesState createState() => _StudyTipsImagesState();
}

class _StudyTipsImagesState extends State<StudyTipsImages> {
  final fb = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: fb.collection('StudyTipsImages').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          return Container(
            height: MediaQuery.of(context).size.height / 10,
            child: ListView.builder(
              addAutomaticKeepAlives: true,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: CachedNetworkImageProvider(
                      snapshot.data!.docs[index]['imageUrl'],
                    ),
                    radius: 30,
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageDetail(
                      imageUrl: snapshot.data!.docs[index]['imageUrl'],
                      initialPage: index,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class ImageDetail extends StatefulWidget {
  final String imageUrl;
  final int initialPage;

  const ImageDetail(
      {Key? key, required this.imageUrl, required this.initialPage})
      : super(key: key);

  @override
  _ImageDetailState createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
  final fb = FirebaseFirestore.instance;
  late PageController pageController;

  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  downloadImage(String imageUrl) async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        onLoading(true, 'saving');
        var imageId = await ImageDownloader.downloadImage(imageUrl);
        onLoading(false, 'saving');
        var path = await ImageDownloader.findPath(imageId!);
        showToast('Image Downloaded : $path');
      } else if (status.isDenied) {
        showToast('Storage permission is necessary for download');
      } else if (status.isRestricted) {
        showToast('Storage permission is necessary for download');
      } else if (status.isPermanentlyDenied) {
        showToast('Allow permission from app setting');
      } else {
        await Permission.storage.request();
      }
    } on PlatformException catch (e) {
      showToast('can not find image');
      print("$e");
    }
  }

  shareImage(String imageUrl) async {
    try {
      var status = await Permission.storage.request();
      var imageId;
      if (status.isGranted) {
        onLoading(true, 'saving');
        imageId = await ImageDownloader.downloadImage(imageUrl);
        onLoading(false, 'saving');
        var path = await ImageDownloader.findPath(imageId);
        await Share.shareFiles([path.toString()]);
      } else if (status.isDenied) {
        showToast('Storage permission is necessary for download');
      } else if (status.isRestricted) {
        showToast('Storage permission is necessary for download');
      } else if (status.isPermanentlyDenied) {
        showToast('Allow permission from app setting');
      } else {
        return await Permission.storage.request();
      }

      if (imageId == null) {
        showToast('can not find image');
      }
    } on PlatformException catch (error) {
      showToast('can not find image');
      print(error);
    }
  }

  onLoading(bool val, String loadingText) {
    if (val) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => SimpleDialog(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator()),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(loadingText))
                      ])),
                ],
              ));
    } else if (!val) {
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      return;
    }
  }

  openDialog(BuildContext context, String imageUrl) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set image as wallpaper ?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text('CANCEL')),
          TextButton(
              onPressed: () async {
                await setWallpaper(context, imageUrl);
              },
              child: Text('SET')),
        ],
      ),
    );
  }

  Future setWallpaper(BuildContext context, String imageUrl) async {
    Navigator.of(context, rootNavigator: true).pop();
    onLoading(true, 'waiting');
    try {
      Future.delayed(Duration(seconds: 1), () async {
        var file = await DefaultCacheManager().getSingleFile(imageUrl);
        await WallpaperManager.setWallpaperFromFile(
            file.path, WallpaperManager.HOME_SCREEN);
        onLoading(false, 'waiting');
        showToast('Wallpaper set');
      });
    } catch (e) {
      print('Failed to get wallpaper.');
    }
  }

  @override
  void initState() {
    pageController =
        PageController(keepPage: true, initialPage: widget.initialPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Life Hacks'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: fb.collection('StudyTipsImages').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            QuerySnapshot<Object?>? res = snapshot.data;
            int _index = widget.initialPage;
            return Column(
              children: [
                Flexible(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: res!.docs.length,
                    itemBuilder: (context, index) {
                      _index = index;

                      return Center(
                        child: CachedNetworkImage(
                          fit: BoxFit.contain,
                          imageUrl: res.docs[index]['imageUrl'],
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, err, error) => Icon(
                            Icons.error,
                            size: 100,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Platform.isAndroid
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              icon: Icon(Icons.image),
                              onPressed: () {
                                openDialog(
                                    context, res.docs[_index]['imageUrl']);
                              }),
                          IconButton(
                              icon: Icon(Icons.download_rounded),
                              onPressed: () async {
                                downloadImage(res.docs[_index]['imageUrl']);
                              }),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              shareImage(res.docs[_index]['imageUrl']);
                            },
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // IconButton(
                          //     icon: Icon(Icons.image),
                          //     onPressed: () {
                          //       openDialog(context, res.docs[_index]['imageUrl']);
                          //     }),
                          IconButton(
                              icon: Icon(Icons.download_rounded),
                              onPressed: () async {
                                downloadImage(res.docs[_index]['imageUrl']);
                              }),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              shareImage(res.docs[_index]['imageUrl']);
                            },
                          ),
                        ],
                      )
              ],
            );
          }
        },
      ),
    );
  }
}
