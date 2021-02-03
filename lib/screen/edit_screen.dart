import 'dart:math';
import 'package:sqlite3/src/api/exception.dart';
import 'package:flutter/material.dart';
import 'package:my_own_card/db/database.dart';
import 'package:my_own_card/screen/word_list_screen.dart';
import '../main.dart';
import 'package:toast/toast.dart';

enum EditStatus { ADD, EDIT }

class EditScreen extends StatefulWidget {
  final EditStatus status;

  final Word word;

  EditScreen({@required this.status, this.word});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  String _titleText = "";

  bool _isQuestionEnabled;

  @override
  void initState() {
    super.initState();
    if (widget.status == EditStatus.ADD) {
      _isQuestionEnabled = true;
      _titleText = "新しい単語の追加";
      questionController.text = "";
      answerController.text = "";
    } else {
      _isQuestionEnabled = false;
      _titleText = "登録した単語の修正";
      questionController.text = widget.word.strQuestion;
      answerController.text = widget.word.strAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => backToWordListScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleText),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.done),
              tooltip: "登録",
              onPressed: () => _onWordRegistered(),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Center(
                  child: Text(
                "問題と答えを入力して「登録」ボタンを押してください",
                style: TextStyle(fontSize: 12),
              )),
              SizedBox(
                height: 30,
              ),
              _questionInputPart(),
              SizedBox(
                height: 50,
              ),
              _answerInputPart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionInputPart() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        children: [
          Text(
            "問題",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            enabled: _isQuestionEnabled,
            controller: questionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30),
          )
        ],
      ),
    );
  }

  Widget _answerInputPart() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        children: [
          Text(
            "答え",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30),
          )
        ],
      ),
    );
  }

  Future<bool> backToWordListScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
    return Future.value(false);
  }

  _insertWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Toast.show("問題と答えの両方を入力しないと登録できません。", context,
          duration: Toast.LENGTH_LONG);
      return;
    }
    showDialog(context: context, builder: (_) => AlertDialog(
        title: Text("登録"),
      content: Text("登録していいですか？"),
      actions: <Widget>[
        FlatButton(
            child: Text("はい"),
            onPressed: () async{
              var word = Word(
                  strQuestion: questionController.text,
                  strAnswer: answerController.text);

              try {
                await database.addWord(word);
                print("OK");
                questionController.clear();
                answerController.clear();

                Toast.show("登録が完了しました。", context, duration: Toast.LENGTH_LONG);
              } on SqliteException  catch (e) {
                print(e.toString());
                Toast.show("この問題は既に登録されている為登録できません。", context,
                    duration: Toast.LENGTH_LONG);
              } finally {
                Navigator.pop(context);
    }
  }
    ),
        FlatButton(
          child: Text("いいえ"),
          onPressed: () => Navigator.pop(context),
    )
        ],
    ));
  }

  _onWordRegistered() {
    if (widget.status == EditStatus.ADD) {
      _insertWord();
    } else {
      _updateWord();
    }
  }

  void _updateWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Toast.show("問題と答えの両方を入力しないと登録できません。", context,
          duration: Toast.LENGTH_LONG);
      return;
    }
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("${questionController.text}の変更"),
      content: Text("変更してもいいですか？"),
      actions: <Widget>[
        FlatButton(
          child: Text("はい"),
          onPressed: () async{
            var word = Word(
                strQuestion: questionController.text,
                strAnswer: answerController.text,
                isMemorized: false);
            try {
              await database.updateWord(word);
              Navigator.pop(context);
              backToWordListScreen();
              Toast.show("修正が完了しました。", context, duration: Toast.LENGTH_LONG);
            } on SqliteException catch (e) {
              Toast.show("何らかの問題が発生した為登録できませんでした。: $e", context,
                  duration: Toast.LENGTH_LONG);
              Navigator.pop(context);
      }
    },
    ),
        FlatButton(
          child: Text("いいえ"),
          onPressed: () => Navigator.pop(context),
    )
        ],
    ));
  }
}

