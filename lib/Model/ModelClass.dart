// To parse this JSON data, do
//
//     final studyTipsModel = studyTipsModelFromJson(jsonString);

import 'dart:convert';

StudyTipsModel studyTipsModelFromJson(String str) =>
    StudyTipsModel.fromJson(json.decode(str));

String studyTipsModelToJson(StudyTipsModel data) => json.encode(data.toJson());

class StudyTipsModel {
  StudyTipsModel({required this.studyTipsCategory});

  List<StudyTipsCategory> studyTipsCategory;

  factory StudyTipsModel.fromJson(Map<String, dynamic> json) => StudyTipsModel(
        studyTipsCategory: List<StudyTipsCategory>.from(
            json["studyTipsCategory"]
                .map((x) => StudyTipsCategory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "studyTipsCategory":
            List<dynamic>.from(studyTipsCategory.map((x) => x.toJson())),
      };
}

class StudyTipsCategory {
  StudyTipsCategory(
      {required this.categoryName,
      required this.imageUrl,
      required this.length,
      required this.initialStudyTip,
      required this.studyTips});

  String categoryName;
  String imageUrl;
  String length;
  String initialStudyTip;
  List<StudyTip> studyTips;

  factory StudyTipsCategory.fromJson(Map<String, dynamic> json) =>
      StudyTipsCategory(
        categoryName: json["categoryName"],
        imageUrl: json["imageUrl"],
        length: json["length"],
        initialStudyTip: json["initialStudyTip"],
        studyTips: List<StudyTip>.from(
            json["studyTips"].map((x) => StudyTip.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categoryName": categoryName,
        "imageUrl": imageUrl,
        "length": length,
        "initialStudyTip": initialStudyTip,
        "studyTips": List<dynamic>.from(studyTips.map((x) => x.toJson())),
      };
}

class StudyTip {
  StudyTip({required this.studyTip});

  String studyTip;

  factory StudyTip.fromJson(Map<String, dynamic> json) => StudyTip(
        studyTip: json["studyTip"],
      );

  Map<String, dynamic> toJson() => {
        "studyTip": studyTip,
      };
}
