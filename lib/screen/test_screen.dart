import 'package:flutter/material.dart';
import 'package:my_own_card/db/database.dart';
import '../main.dart';

enum TestStatus { BEFORE_START, SHOW_QUESTION, SHOW_ANSWER, FINISHED }

class TestScreen extends StatefulWidget {
  final bool isIncludedMemorizedWords;

  TestScreen({this.isIncludedMemorizedWords});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _numberOfQuestion = 0;
  String _textQuestion = "";
  String _textAnswer = "";
  bool _isMemorized = false;
  List<Word> _testDataList = List();
  TestStatus _testStatus;
  bool _isQuestionCardVisible = false;
  bool _isAnswerCardVisible = false;
  bool _isCheckBoxVisible = false;
  bool _isFabVisible = false;
  int _index = 0; //今何問目か
  Word _currentWord;

  @override
  void initState() {
    super.initState();
    _getTestData();
  }

  void _getTestData() async {
    if (widget.isIncludedMemorizedWords) {
      _testDataList = await database.allWords;
    } else {
      _testDataList = await database.allWordsExcludedMemorized;
    }

    _testDataList.shuffle();
    _testStatus = TestStatus.BEFORE_START;
    _index = 0;

    print(_testDataList.toString());

    setState(() {
      _isQuestionCardVisible = false;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;

      _numberOfQuestion = _testDataList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _finishTestScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("確認テスト"),
          centerTitle: true,
        ),
        floatingActionButton: _isFabVisible
            ? FloatingActionButton(
          onPressed: () => goNextStatus(),
          child: Icon(Icons.skip_next),
          tooltip: "次に進む",
        )
            : null,
        body: Stack(
            children: [Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                _numberOfQuestionsPart(),
                SizedBox(
                  height: 20.0,
                ),
                _questionCardPart(),
                SizedBox(
                  height: 10.0,
                ),
                _answerCardPart(),
                SizedBox(
                  height: 10.0,
                ),
                _isMemorizedCheckPart(),
              ],
            ),
              _endMessage(),
            ]
        ),
      ),
    );
  }

  //残り問題数表示部分
  Widget _numberOfQuestionsPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "残り問題数",
          style: TextStyle(fontSize: 14.0),
        ),
        SizedBox(
          width: 30.0,
        ),
        Text(
          _numberOfQuestion.toString(),
          style: TextStyle(fontSize: 24.0),
        ),
      ],
    );
  }

  //問題カード表示部分
  Widget _questionCardPart() {
    if (_isQuestionCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.asset("assets/images/image_flash_question.png"),
          Text(
            _textQuestion,
            style: TextStyle(color: Colors.black, fontSize: 20.0),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  //答えカード表示部分
  Widget _answerCardPart() {
    if (_isAnswerCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.asset("assets/images/image_flash_answer.png"),
          Text(
            _textAnswer,
            style: TextStyle(fontSize: 20.0),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  //暗記済みチェック部分
  Widget _isMemorizedCheckPart() {
    if (_isCheckBoxVisible) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        //左側にチェックボックスを作りたい場合は、Rowでcheckbox,textを別で並べる処理が必要！
        child: CheckboxListTile(
            title: Text(
              "暗記済にする場合はチェックを入れて下さい",
              style: TextStyle(fontSize: 12.0),
            ),
            value: _isMemorized,
            onChanged: (value) {
              setState(() {
                _isMemorized = value;
              });
            },
            ),
      );
    } else {
      return Container();
    }
  }

  //テスト終了メッセージ
  Widget _endMessage() {
    if (_testStatus == TestStatus.FINISHED) {
      return Center(child: Text("テスト終了", style: TextStyle(fontSize: 50.0),));
    } else {
      return Container();
    }
  }

  goNextStatus() async {
    switch (_testStatus) {
      case TestStatus.BEFORE_START:
        _testStatus = TestStatus.SHOW_QUESTION;
        _showQuestion();
        break;
      case TestStatus.SHOW_QUESTION:
        _testStatus = TestStatus.SHOW_ANSWER;
        _showAnswer();
        break;
      case TestStatus.SHOW_ANSWER:
        await _updateMemorizedFlag();
        if (_numberOfQuestion <= 0) {
          setState(() {
            _isFabVisible = false;
            _testStatus = TestStatus.FINISHED;
          });
        } else {
          _testStatus = TestStatus.SHOW_QUESTION;
          _showQuestion();
        }
        break;
      case TestStatus.FINISHED:
        break;
    }
  }

  void _showQuestion() {
    _currentWord = _testDataList[_index];
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;
      _textQuestion = _currentWord.strQuestion;
    });
    _numberOfQuestion -= 1;
    _index += 1;
  }

  void _showAnswer() {
    setState(() {
      _isCheckBoxVisible = true;
      _isAnswerCardVisible = true;
      _isFabVisible = true;
      _isQuestionCardVisible = true;
      _textAnswer = _currentWord.strAnswer;
      _isMemorized = _currentWord.isMemorized;
    });
  }

  Future<void> _updateMemorizedFlag() async {
    var updateWord = Word(
        strQuestion: _currentWord.strQuestion,
        strAnswer: _currentWord.strAnswer,
        isMemorized: _isMemorized);
    await database.updateWord(updateWord);
    print(updateWord.toString());
  }

  Future<bool> _finishTestScreen() async{
    return await showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("テストの終了"),
      content: Text("テストを終了してもいいですか？"),
      actions: [
        FlatButton(
          onPressed: (){
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Text("はい"),
        ),

        FlatButton(onPressed: () => Navigator.pop(context),
          child: Text("いいえ"),
        )
      ],
    )) ?? false;
  }


}
