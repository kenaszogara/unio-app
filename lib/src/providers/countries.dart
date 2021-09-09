import 'package:Unio/src/service/http_service.dart';
import 'package:Unio/src/utilities/global.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

class CountryProvider with ChangeNotifier {
  List<String> _countries = [];
  List<String> get countries => _countries;
  set countries(List<String> countries) {
    this._countries = countries;
    notifyListeners();
  }

  String _selectedCountry;
  String get selectedCountry => _selectedCountry;
  set selectedCountry(String country) {
    this._selectedCountry = country;
    notifyListeners();
  }

  String _defaultCountry;
  String get defaultCountry => _defaultCountry;
  set defaultCountry(String country) {
    this._defaultCountry = country;
    notifyListeners();
  }

  dynamic _countryResult;
  dynamic get countryResult => _countryResult;

  bool _checkBoxValue = false;
  bool get checkBoxValue => _checkBoxValue;
  set checkBoxValue(bool value) {
    this._checkBoxValue = value;
    notifyListeners();
  }

  bool _showCheckBox = false;
  bool get showCheckBox => _showCheckBox;
  set showCheckBox(bool value) {
    this._showCheckBox = value;
    notifyListeners();
  }

  int selectedCountryId() {
    if (_selectedCountry == null) {
      return null;
    }
    var selected = _countryResult
        .firstWhere((element) => element['name'] == _selectedCountry);
    return selected['id'];
  }

  Future<dynamic> initCountries() async {
    String url = SERVER_DOMAIN + 'countries';
    String token = Global.instance.apiToken;

    getService(url, token: token, onSuccess: (response) async {
      print(response.body);

      _countries.clear();
      _countryResult = json.decode(response.body)['data'];

      for (var i = 0; i < _countryResult.length; i++) {
        _countries.add(_countryResult[i]['name'].toString());
      }

      if (Global.instance.authCountryId != null) {
        var selected = await _countryResult.firstWhere(
            (element) => element['id'] == Global.instance.authCountryId);
        _selectedCountry = selected['name'];
        _defaultCountry = selected['name'];
        _checkBoxValue = true;
        _showCheckBox = true;
      } else {
        _selectedCountry = null;
        _defaultCountry = null;
        _checkBoxValue = false;
        _showCheckBox = false;
      }

      notifyListeners();
    });
  }

  Future<dynamic> getCountries() async {
    String url = SERVER_DOMAIN + 'countries';
    String token = Global.instance.apiToken;

    getService(url, token: token, onSuccess: (response) async {
      print(response.body);

      _countries.clear();
      _countryResult = json.decode(response.body)['data'];

      for (var i = 0; i < _countryResult.length; i++) {
        _countries.add(_countryResult[i]['name'].toString());
      }

      notifyListeners();
    });
  }

  Future<dynamic> addDefault(context) async {
    var selected = _countryResult
        .firstWhere((element) => element['name'] == _selectedCountry);
    int _selectedCountryId = selected['id'];

    String userId = Global.instance.authId.toString();
    String token = Global.instance.apiToken.toString();
    String url = SERVER_DOMAIN + 'users/' + userId;

    putService(url, token: token, body: {
      'country_id': _selectedCountryId.toString(),
    }, onSuccess: (response) {
      print(response.body);
      dynamic result = json.decode(response.body);
      if (result["success"]) {
        Global.instance.authCountryId = result["data"]["biodata"]["country_id"];
        storage.write(
            key: 'authCountryId', value: _selectedCountryId.toString());
        showOkAlertDialog(context: context, title: result['message']);
      } else {
        Global.instance.authCountryId = null;
        storage.write(key: 'authCountryId', value: null);
        print("UPDATE NOT SUCCESSFUL");
        showOkAlertDialog(context: context, title: "UPDATE NOT SUCCESSFUL");
      }

      notifyListeners();
    });
  }

  Future<dynamic> removeDefault(context) async {
    _defaultCountry = null;

    String userId = Global.instance.authId.toString();
    String token = Global.instance.apiToken.toString();
    String url = SERVER_DOMAIN + 'users/' + userId;

    putService(url, token: token, body: {
      'country_id': null,
    }, onSuccess: (response) {
      print(response.body);
      dynamic result = json.decode(response.body);
      if (result["success"]) {
        Global.instance.authCountryId = null;
        storage.write(key: 'authCountryId', value: null);
        showOkAlertDialog(context: context, title: result['message']);
      } else {
        Global.instance.authCountryId = null;
        storage.write(key: 'authCountryId', value: null);
        print("UPDATE NOT SUCCESSFUL");
        showOkAlertDialog(context: context, title: "UPDATE NOT SUCCESSFUL");
      }

      notifyListeners();
    });
  }
}
