import 'dart:convert';
import 'dart:io';

import 'package:Unio/config/ui_icons.dart';
import 'package:Unio/src/models/questionaire_score.dart';
import 'package:Unio/src/models/route_argument.dart';
import 'package:Unio/src/utilities/global.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:Unio/src/models/Questions.dart';
import 'package:Unio/src/screens/score/score_screen.dart';
import 'package:http/http.dart' as http;
import 'package:Unio/src/models/category.dart';

// We use get package for our state management

class QuestionController extends GetxController
    with SingleGetTickerProviderMixin {
  // Lets animated our progress bar

  AnimationController _animationController;
  Animation _animation;
  // so that we can access our animation outside
  Animation get animation => this._animation;

  PageController _pageController;
  PageController get pageController => this._pageController;

  List<Question> _questions;
  List<Question> get questions => this._questions;

  dynamic _extraQuestions;
  dynamic get extraQuestions => this._extraQuestions;

  QuestionaireScore _score;
  QuestionaireScore get score => this._score;

  bool _isAnswered = false;
  bool get isAnswered => this._isAnswered;
  void set isAnswered(bool value) {
    this._isAnswered = value;
  }

  bool _hasExtra = false;
  bool get hasExtra => this._hasExtra;

  int _correctAns;
  int get correctAns => this._correctAns;

  int _selectedAns;
  int get selectedAns => this._selectedAns;

  // for more about obs please check documentation
  RxInt _questionNumber = 1.obs;
  RxInt get questionNumber => this._questionNumber;

  int _numOfCorrectAns = 0;
  int get numOfCorrectAns => this._numOfCorrectAns;

  // called immediately after the widget is allocated memory
  @override
  void onInit() {
    _pageController = new PageController();
    _score = new QuestionaireScore();
    fetchQuestion();
    super.onInit();
  }

  // // called just before the Controller is deleted from memory
  @override
  void onClose() {
    super.onClose();
    // _animationController.dispose();
    _pageController.dispose();
  }

  // get data from api
  Future<List<Question>> fetchQuestion() async {
    final url = Uri.parse('${SERVER_DOMAIN}questionnaire_image');
    final token = await storage.read(key: 'apiToken');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // print(response.body);
      var res = json.decode(response.body);
      var data = res['data']['basic_question'];
      var extra = res['data']['extra_question'];

      print(data);

      _questions =
          List<Question>.from(data.map((model) => Question.fromJson(model)));
      // print(_questions);

      _extraQuestions = extra;

      print(_extraQuestions);

      return _questions;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load questions');
    }
  }

  void checkAns(String answer, int selectedIndex, int questionNumber) {
    // because once user press any option then it will run
    if (!_isAnswered) {}
    _isAnswered = true;
    // _correctAns = 2;
    _selectedAns = selectedIndex;

    // add score by answer
    _score.addScore(answer, questionNumber);
    update();
  }

  void prevQuestion() {
    if (_questionNumber.value != 1) {
      _isAnswered = true;
      _pageController.previousPage(
          duration: Duration(milliseconds: 250), curve: Curves.ease);
    }
  }

  void nextQuestion(BuildContext context) {
    if (_questionNumber.value != _questions.length) {
      if (!_isAnswered) {
        AlertDialog(title: Text('Please choose the answer first'));
      } else {
        _isAnswered = false;
        _pageController.nextPage(
            duration: Duration(milliseconds: 250), curve: Curves.ease);
      }
    } else {
      // updateTheQnNum(0);
      if (_isAnswered) {
        adviceStudent(context);
      }

      // Get package provide us simple way to naviigate another page
      // Get.to(() => AdviceWidget());
    }
  }

  void updateTheQnNum(int index) {
    _questionNumber.value = index + 1;
  }

  void resetDefault() {
    _isAnswered = false;
    _questionNumber = 1.obs;
    _correctAns = null;
    _selectedAns = null;
    _pageController.dispose();
    _pageController = new PageController();
    _score = new QuestionaireScore();
    update();
  }

  void resetScore() {
    _score = new QuestionaireScore();
    _hasExtra = true;
    // _oldHc = null;
    // _extraHc = null;
    update();
  }

  void adviceStudent(context) async {
    dynamic finalScore = await _score.calculateFinalScore();

    // dynamic finalScore = {
    //   "hasExtra": true,
    //   "score": "__",
    //   "extras": [
    //     ["R", "I"],
    //     ["A", "S", "E"]
    //   ],
    //   "extra_images": [
    //     [
    //       {
    //         "name": "Interested in automotive",
    //         "src":
    //             "http:\/\/dev2.unio.id\/kuisoner\/images\/Repair a thing (R).png",
    //         "type": "R"
    //       },
    //       {
    //         "name": "Learn and acquire knowledge",
    //         "src":
    //             "http:\/\/dev2.unio.id\/kuisoner\/images\/Solving a law case(I).jpg",
    //         "type": "I"
    //       }
    //     ],
    //     [
    //       {
    //         "name": "Generate new ideas",
    //         "src":
    //             "http:\/\/dev2.unio.id\/kuisoner\/images\/Writing a poem(A).jpg",
    //         "type": "A"
    //       },
    //       {
    //         "name": "Connect with people",
    //         "src": "http:\/\/dev2.unio.id\/kuisoner\/images\/Teaching(S).jpg",
    //         "type": "S"
    //       },
    //       {
    //         "name": "Manage people",
    //         "src":
    //             "http:\/\/dev2.unio.id\/kuisoner\/images\/Present a thing(E).jpg",
    //         "type": "E"
    //       }
    //     ]
    //   ]
    // };

    String score = finalScore['score'];
    // update hc of student profile

    if (finalScore['hasExtra']) {
      _hasExtra = true;
      // _oldHc = finalScore['old_hc'];
      // _extraHc = finalScore['extra_hc'];

      print(finalScore['score']);

      update();

      // if (finalScore['extras'].length == 1) {
        // if (finalScore['extras'][0].length == 2) {
          Navigator.of(context).pushReplacementNamed('/ExtraQuestionTwo',
              arguments: new RouteArgument(argumentsList: [
                finalScore['score'],
                finalScore['extra_images'],
                _extraQuestions,
                finalScore,
              ]));
      //   } else {
      //     Navigator.of(context).pushReplacementNamed('/ExtraQuestion',
      //         arguments: new RouteArgument(argumentsList: [
      //           finalScore['old_hc'],
      //           finalScore['extra_hc'],
      //           _extraQuestions,
      //         ]));
      //   }
      // } else {
        // combination of both
      // }

      resetScore();
    } else {
      try {
        final url =
            Uri.parse('${SERVER_DOMAIN}user/set-hc/${Global.instance.authId}');
        final token = await storage.read(key: 'apiToken');
        final response = await http.post(url, headers: {
          'Authorization': 'Bearer $token',
        }, body: {
          'hc': score,
        });

        print(_score.score);
        print(response);

        // save to Global instance
        // Global.instance.authHc = finalScore;

        // save to local storage
        Global.instance.authHc = score;
        await storage.write(key: 'authHc', value: score);

        print('${_score.score} added to user profile');
        resetScore();

        Navigator.of(context).pushReplacementNamed('/Advice',
            arguments: new RouteArgument(argumentsList: [
              Category(
                  'Match With Me', UiIcons.compass, true, Colors.redAccent, []),
              ''
            ]));
      } on SocketException {
        throw 'Tidak ada koneksi internet. Silahkan coba lagi.';
      }
    }
  }
}
