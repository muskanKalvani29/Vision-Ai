import 'package:flutter/material.dart';
import 'package:google_ml_kit_example/VisionDetectorViews/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

// enum Language { english, hindi, gujarati }

class SelectLanguage extends StatefulWidget {
  // ValueNotifier<int> langNotifier=new ValueNotifier(1);
  SelectLanguage({Key? key}) : super(key: key);

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  int? lang;

  // _SelectLanguageState()  {
  //   getLang();
  // }
  setLang() async {
    final SharedPreferences setLanguage = await SharedPreferences.getInstance();
    await setLanguage.setInt("lang", lang!);
  }

  @override
  void initState() {
    // print('POPUP INIT+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');  
     getLang();
    super.initState();
  }

  getLang() async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    // if (instance.getInt('lang') == null) {
    //   await instance.setInt("lang", 1);
    // }
    this.lang = instance.getInt("lang")!;
    // print('VALUE OF SHARED IN POP UP $lang');
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('POPUP BUILD+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');  
    
    return Container(
      child: AlertDialog(
        title: const Text('Select Language'),
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<int>(
                value: 1,
                groupValue: lang,
                title: Text("English"),
                onChanged: (value) => setState(() {
                      lang = value;
                      // print('VALUE $lang');
                    })),
            RadioListTile<int>(
                value: 2,
                groupValue: lang,
                title: Text("Hindi"),
                onChanged: (value) => setState(() {
                      lang = value;
                      // print('VALUE $lang');
                    })),
            RadioListTile<int>(
                value: 3,
                groupValue: lang,
                title: Text("Gujarati"),
                onChanged: (value) => setState(() {
                      lang = value;
                      // print('VALUE $lang');
                    })),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              setState(() {
                setLang();

              });

              // widget.langNotifier.value=lang!;
              // Language.lang=lang!;
              Navigator.pop(context);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
