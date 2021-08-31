import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studytips/Model/ModelClass.dart';
import 'package:studytips/Services/SqlServices.dart';
import 'package:studytips/View/StudyTipsList.dart';

class StudyTipsCategory extends StatefulWidget {
  @override
  _StudyTipsCategoryState createState() => _StudyTipsCategoryState();
}

class _StudyTipsCategoryState extends State<StudyTipsCategory> {
  Future<StudyTipsModel> getData() async {
    var res = await rootBundle.loadString('assets/Database.json');
    final studyTipsModel = studyTipsModelFromJson(res);
    return studyTipsModel;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SqlServices>(
      builder: (context, sqlServices, child) {
        return FutureBuilder(
          future: sqlServices.queryCategoryTable(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.red,
              ));
            } else {
              List res = snapshot.data as List;
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: res.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(res[index]['categoryName'].toString()),
                  subtitle: Text(
                    res[index]['initialStudyTip'].toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage(res[index]['imageUrl']),
                  ),
                  trailing: Text(res[index]['categoryLength'].toString()),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudyTipsList(
                        title: res[index]['categoryName'],
                        categoryId: res[index]['categoryId'],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
