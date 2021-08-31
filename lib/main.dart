import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Services/DatabaseHelper.dart';
import 'Services/SqlServices.dart';
import 'View/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  databaseHelper.getDatabase;
  SqlServices().mopubInit();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (context) => runApp(StudyTipsApp()),
  );
}

class StudyTipsApp extends StatefulWidget {
  @override
  _StudyTipsAppState createState() => _StudyTipsAppState();
}

class _StudyTipsAppState extends State<StudyTipsApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SqlServices>(
      create: (context) => SqlServices(),
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'Study Tips',
          theme: ThemeData(primaryColor: Color(0xff7D8D97)),
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        );
      },
    );
  }
}
