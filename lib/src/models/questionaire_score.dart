class QuestionaireScore {
  Map _hollandCode;
  dynamic _score;
  dynamic get score => _score;

  Map _answers = new Map();
  Map get answers => _answers;

  bool _hasExtra = false;
  bool get hasExtra => _hasExtra;

  List<dynamic> _extraQuestions;
  List<dynamic> get extraQuestions => _extraQuestions;

  QuestionaireScore() {
    this._hollandCode = {
      'R': 0,
      'I': 0,
      'A': 0,
      'S': 0,
      'E': 0,
      'C': 0,
    };
  }

  void addScore(String type, int index) {
    print(type);
    switch (type) {
      case 'R':
        _answers[index] = 'R';
        break;
      case 'I':
        _answers[index] = 'I';
        break;
      case 'A':
        _answers[index] = 'A';
        break;
      case 'S':
        _answers[index] = 'S';
        break;
      case 'E':
        _answers[index] = 'E';
        break;
      case 'C':
        _answers[index] = 'C';
        break;
    }
  }

  void countScore() {
    _answers.forEach((key, value) {
      switch (value) {
        case 'R':
          _hollandCode['R'] += 1;
          break;
        case 'I':
          _hollandCode['I'] += 1;
          break;
        case 'A':
          _hollandCode['A'] += 1;
          break;
        case 'S':
          _hollandCode['S'] += 1;
          break;
        case 'E':
          _hollandCode['E'] += 1;
          break;
        case 'C':
          _hollandCode['C'] += 1;
          break;
      }
    });
  }

  dynamic calculateFinalScore() {
    countScore();

    var sortedKeys = _hollandCode.keys.toList(growable: false)
      ..sort((k1, k2) => _hollandCode[k2].compareTo(_hollandCode[k1]));
    print(sortedKeys);

    Map sortedMap = new Map.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => _hollandCode[k]);
    print(sortedMap);

    // ONLY WORKS IF DATA IS SORTED FROM HIGH TO LOW
    // List code = sortedMap.keys.toList();
    List hcTemp = [];
    List scoreTemp = [];
    var hcMap = {};

    for (var i = 0; i < 3; i++) {
      var hc = sortedKeys[i];
      var score = sortedMap[hc];
      
      hcMap[i] = sortedKeys[i];

      if (scoreTemp.isEmpty) {
        hcTemp.add(hc);
        scoreTemp.add(score);
        print(i);
      } else {
        if (scoreTemp.length < 3) {
          if (scoreTemp[0] != score) {
            hcTemp.clear();
            scoreTemp.clear();

            hcTemp.add(hc);
            scoreTemp.add(score);
          } else {
            hcTemp.add(hc);
            scoreTemp.add(score);
          }
        }
      }
    }

    if (hcTemp.length > 1) {
      _score = {
        'has_extra': true,
        'score': sortedKeys[0] + sortedKeys[1] + sortedKeys[2],
        'old_hc': [sortedKeys[0], sortedKeys[1], sortedKeys[2]],
        'extra_hc': hcTemp,
      };
    } else {
      _score = {
        'has_extra': false,
        'score': sortedKeys[0] + sortedKeys[1] + sortedKeys[2],
      };
    }

    return _score;
  }
}
