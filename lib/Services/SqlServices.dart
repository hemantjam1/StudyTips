import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DatabaseHelper.dart';
import 'package:mopub_flutter/mopub.dart';
import 'package:mopub_flutter/mopub_banner.dart';
import 'package:mopub_flutter/mopub_interstitial.dart';
import '../Model/ModelClass.dart';

class SqlServices extends ChangeNotifier {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  static bool isDbAvailable = false;
  static final bannerId = '475b04ebacfc474ead44f872af85c101a';
  // //android banner test iD
  static final interstitialId = "91562520ec8b4245be09774d72bffd6d";
  //android interstitial test Id
  // Android
  // Banner. : 475b04ebacfc474ead44f872af85c101
  // Full screen : 91562520ec8b4245be09774d72bffd6d
  static late MoPubInterstitialAd interstitialAd;

  mopubInit() {
    try {
      MoPub.init(interstitialId).then((value) => _loadInterstitialAd());
    } on PlatformException catch (e) {
      print('something wrong in mopub$e');
    }
    try {
      MoPub.init(bannerId);
    } on PlatformException catch (e) {
      print('something wrong in mopub banner ad$e');
    }
  }

  _loadInterstitialAd() {
    interstitialAd = MoPubInterstitialAd(
      interstitialId,
      (result, args) {},
      reloadOnClosed: true,
    );
    interstitialAd.load();
  }

  Widget showBannerAd() {
    return Platform.isAndroid
        ? MoPubBannerAd(
            adUnitId: bannerId,
            bannerSize: BannerSize.STANDARD,
            keepAlive: true,
            listener: (result, dynamic) {})
        : Container(height: 20);
  }

  insertData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var res = await rootBundle.loadString('assets/Database.json');
    final studyTipsModel = studyTipsModelFromJson(res);

    for (int i = 0; i < studyTipsModel.studyTipsCategory.length; i++) {
      Map<String, dynamic> categoryRow = {
        DatabaseHelper.categoryColumnId: i,
        DatabaseHelper.categoryColumnName:
            studyTipsModel.studyTipsCategory[i].categoryName,
        DatabaseHelper.categoryImageUrl:
            studyTipsModel.studyTipsCategory[i].imageUrl,
        DatabaseHelper.categoryLength:
            studyTipsModel.studyTipsCategory[i].length,
        DatabaseHelper.categoryInitialStudyTip:
            studyTipsModel.studyTipsCategory[i].initialStudyTip
      };
      await databaseHelper.insertIntoCategory(categoryTableRow: categoryRow);
      for (int j = 0;
          j < studyTipsModel.studyTipsCategory[i].studyTips.length;
          j++) {
        Map<String, dynamic> studyTipsRow = {
          DatabaseHelper.categoryId: i,
          DatabaseHelper.studyTipsColumnId: j,
          DatabaseHelper.studyTipsColumn:
              studyTipsModel.studyTipsCategory[i].studyTips[j].studyTip,
          DatabaseHelper.isFav: 'false'
        };
        await databaseHelper.insertIntoStudyTips(
            categoryDetailTableRow: studyTipsRow);
      }
    }
    queryCategoryTable();
    pref.setBool('isDB', true);
    notifyListeners();
  }

  Future queryCategoryTable() async {
    var res = await databaseHelper.queryCategoryTable('categoryTable');
    notifyListeners();
    return res;
  }

  Future queryStudyTipsTable() async {
    var res = await databaseHelper.queryCategoryTable('lifeHacksTable');
    notifyListeners();
    return res;
  }

  Future singleStudyTips({required int studyTipsId, required int catId}) async {
    String studyTip;
    List studyTipsList = [];
    var res = await databaseHelper.singleStudyTips(
        studyTipsId: studyTipsId, catId: catId);
    studyTipsList = res;
    studyTip = studyTipsList.first['studyTip'];
    //  print("ressssssssssssssssssssssss$res");
    return studyTip;
  }

  Future<bool> checkDb() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    notifyListeners();
    return pref.getBool('isDB') ?? false;
  }

  fetchDb(bool isDbAvailable) {
    if (!isDbAvailable) {
      insertData();
    } else {
      queryCategoryTable();
    }
    notifyListeners();
  }

  queryCategory({required int catId}) async {
    var res = await databaseHelper.queryCategory(catId: catId);
    notifyListeners();
    return res;
  }

  queryFavorite() async {
    var res = await databaseHelper.favQuery();
    notifyListeners();
    return res;
  }

  addToFavorite(
      {required int studyTipsId,
      required String isFav,
      required int catId}) async {
    await databaseHelper.update(
        studyTipsId: studyTipsId, isFav: isFav, catId: catId);
    notifyListeners();
  }

  Future favoriteCopy({required int studyTipsId, required int catId}) async {
    List favList = [];
    String favCopy;
    var res = await databaseHelper.favoriteCopy(
        catId: catId, studyTipsId: studyTipsId);
    favList = res;
    favCopy = favList.first['studyTip'];
    return favCopy;
  }
}
