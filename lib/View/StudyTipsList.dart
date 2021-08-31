import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytips/Services/SqlServices.dart';
import 'package:studytips/View/StudyTipsDetails.dart';

class StudyTipsList extends StatefulWidget {
  final int categoryId;
  final String title;

  const StudyTipsList({Key? key, required this.title, required this.categoryId})
      : super(key: key);
  @override
  _StudyTipsListState createState() => _StudyTipsListState();
}

class _StudyTipsListState extends State<StudyTipsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Consumer<SqlServices>(
        builder: (context, sqlServices, child) {
          return FutureBuilder(
            future: sqlServices.queryCategory(catId: widget.categoryId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                List res = snapshot.data as List;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: res.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 8),
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
                            builder: (context) => StudyTipsDetails(
                              title: widget.title,
                              categoryId: widget.categoryId,
                              isFav: res[index]['isFav'],
                              pageNumber: index,
                            ),
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
