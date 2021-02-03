import 'package:flutter/material.dart';
import 'package:my_own_card/part/button_icon.dart';
import 'package:my_own_card/screen/test_screen.dart';
import 'package:my_own_card/screen/word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isIncludedMemorizedWords = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Image.asset("assets/images/image_title.png")),
            _titleText(),
            Divider(
              height: 30,
              color: Colors.white,
              indent: 8,
              endIndent: 8,
            ),
            ButtonWithIcon(
              onPressed: () => _startTestScreen(context),
              icon: Icon(Icons.play_arrow),
              label: "確認テストをする",
            ),
            SizedBox(
              height: 10,
            ),
            //_radioButtons(),
            _switch(),
            SizedBox(
              height: 30,
            ),
            ButtonWithIcon(
              onPressed: () => _startWordListScreen(context),
              icon: Icon(Icons.list),
              label: "単語帳を見る",
              color: Colors.grey,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "powered by Tyantyaro LLC 2020",
              style: TextStyle(fontFamily: "Mont"),
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleText() {
    return Column(
      children: [
        Text(
          "私だけの単語帳",
          style: TextStyle(fontSize: 40),
        ),
        Text("My Own Frashcard",
            style: TextStyle(fontSize: 24, fontFamily: "Mont")),
      ],
    );
  }

  Widget _radioButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Column(
        children: [
          RadioListTile(
            value: false,
            groupValue: isIncludedMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: Text(
              "暗記済みの単語を除外する",
              style: TextStyle(fontSize: 16),
            ),
          ),
          RadioListTile(
            value: true,
            groupValue: isIncludedMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: Text(
              "暗記済みの単語を含む",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  _onRadioSelected(value) {
    setState(() {
      isIncludedMemorizedWords = value;
    });
  }

  _startWordListScreen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
  }

  _startTestScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(
                  isIncludedMemorizedWords: isIncludedMemorizedWords,
                )));
  }

  Widget _switch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SwitchListTile(
        title: Text("暗記済みの単語を含む"),
        value: isIncludedMemorizedWords,
        onChanged: (value){
          setState(() {
            isIncludedMemorizedWords = value;
          });
        },
        secondary: Icon(Icons.sort),
      ),
    );
  }
}
