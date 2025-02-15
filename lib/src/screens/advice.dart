import 'package:Unio/src/models/fos.dart';
import 'package:Unio/src/utilities/global.dart';
import 'package:Unio/src/widgets/AdviceListItemWidget.dart';
import 'package:Unio/src/widgets/CustomDropdownSearchWidget.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
// import 'package:sliver_tools/sliver_tools.dart';
import '../../config/ui_icons.dart';
import '../models/category.dart';
import '../models/route_argument.dart';
import '../widgets/DrawerWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/advice.dart';
import 'package:Unio/src/utilities/global.dart';

// ignore: must_be_immutable
class AdviceWidget extends StatefulWidget {
  RouteArgument routeArgument;
  Category _category;
  String _keyword;

  AdviceWidget({Key key, this.routeArgument}) {
    _category = this.routeArgument.argumentsList[0] as Category;
    _keyword = this.routeArgument.argumentsList[1] as String;
  }

  @override
  _AdviceWidgetState createState() => _AdviceWidgetState();
}

class _AdviceWidgetState extends State<AdviceWidget> {
  final myController = TextEditingController();
  final univeristyNameSearchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController scrollController = ScrollController();
  bool hasMore;
  bool loadingData;
  bool _initialFosData;
  bool _bookmarkExpanded;
  bool _fosListSelectAll; // CHECKBOX FOR SELECT ALL FOS
  int page;
  int limit;

  String subUrl = 'match-with-me-mobile';
  String entity = 'match-with-me-mobile';

  AdviceList _adviceList;
  AdviceList _bookmarkedList;
  bool shouldPop;

  List<Fos> _fosList;
  List<String> level = [];

  // Main Search
  String majorName;

  // filters
  Map selectedCip; // CHECKBOX FILTER VALUE
  List<String> levels;
  int countryId;
  int stateId;
  String universityName;
  String levelDegree;

  // RIGHT DRAWER
  bool isRightDrawerOpen;
  double xOffset;
  double yOffset;

  // DROPDOWN SEARCH
  DropdownSearch<String> stateDropDown;
  DropdownSearch<String> countryDropDown;

  List<DropdownMenuItem> countries;
  List<DropdownMenuItem> states;

  List<String> countryList;
  List<String> stateList;

  var countryRes;
  var stateRes;
  var levelRes;

  String _valCountry;
  String _valCountryId;

  String _valState;

  bool levelDefault = false;
  String levelDefaultValue = '';

  bool countryDefault = false;
  String countryDefaultValue = '';

  bool showCountryDefault = false;
  bool showLevelDefault = false;

  @override
  void initState() {
    setParam();

    getData();

    // getCountry();

    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        print('============ _scrollListener end end ' +
            hasMore.toString() +
            '======' +
            page.toString());
        if (hasMore && !loadingData) {
          page += 1;

          getData();
        }
      }
    });

    myController.addListener(handleSearchController);
    univeristyNameSearchController
        .addListener(handleUniversityNameSearchController);
  }

  @override
  void dispose() {
    myController.dispose();
    univeristyNameSearchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void handleSearchController() {
    setState(() {
      widget._keyword = myController.text;
    });
  }

  void handleUniversityNameSearchController() {
    setState(() {
      universityName = univeristyNameSearchController.text;
    });
  }

  void openRightDrawer() {
    setState(() {
      isRightDrawerOpen = true;
      xOffset = MediaQuery.of(context).size.width * 1 / 4;
    });
  }

  void closeRightDrawer() {
    setState(() {
      isRightDrawerOpen = false;
      xOffset = MediaQuery.of(context).size.width;
    });
  }

  void setParam() {
    xOffset = 500;
    yOffset = 0;
    isRightDrawerOpen = false;

    page = 1;
    limit = 15;

    hasMore = true;
    loadingData = false;
    _initialFosData = true;

    _bookmarkExpanded = true;
    _fosListSelectAll = true;

    _adviceList = new AdviceList();
    _bookmarkedList = new AdviceList();
    shouldPop = true;

    _fosList = [];
    selectedCip = new Map();

    countries = [];
    countryList = [];
    countryRes = [];

    states = [];
    stateList = [];
    stateRes = [];

    if (Global.instance.authCountryId != null) {
      countryId = Global.instance.authCountryId;
    }
  }

  void getData() async {
    var userId = await Global.instance.authId;

    // TODOS: perbaiki ini kampret
    // var userHc = await Global.instance.authHc;
    var userHc = await storage.read(key: 'authHc');
    var token = await Global.instance.apiToken;

    Map<String, String> headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    headers.addAll(
        <String, String>{HttpHeaders.authorizationHeader: 'Bearer $token'});

    // check level_id in search preference
    if (levelRes == null) {
      getLevel();
    }

    // check country_id in search preference
    if (_initialFosData) {
      _initialFosData = false;

      try {
        var _url = SERVER_DOMAIN + 'match-with-me/cip_v2/' + userHc;
        // var _url = 'http://10.0.2.2:8000/api/' +
        //     'match-with-me/cip_v2' +
        //     "/" +
        //     userHc;

        final _client = new http.Client();
        final _response = await _client
            .get(
          Uri.parse(_url),
          headers: headers,
        )
            .timeout(Duration(seconds: 60), onTimeout: () {
          throw 'Koneksi terputus. Silahkan coba lagi.';
        });

        if (_response.statusCode == 200) {
          List jsonFos =
              await json.decode(_response.body)['data']['matchedFos'];

          if (jsonFos != null && jsonFos.isNotEmpty) {
            for (var i = 0; i < jsonFos.length; i++) {
              print('fos: $i');
              setState(() {
                _fosList.add(new Fos(
                  cip: jsonFos[i]['cip'],
                  name: jsonFos[i]['name'],
                  // hc: jsonFos[i]['hc'],
                ));

                selectedCip[i] = jsonFos[i]['cip'];
              });
            }

            // await getBookmarkedMajors();
            List _cip = [];

            _fosList.forEach((element) {
              _cip = _cip + element.cip;
            });

            print(userId);
            print(_cip);

            getCountry(_cip);
          } else {
            _fosList.clear();
            selectedCip.clear();
          }
        } else {
          String error = json.decode(_response.body)['error'];
          throw (error == '') ? 'Gagal memproses data' : error;
        }
      } on SocketException {
        throw 'Tidak ada koneksi internet. Silahkan coba lagi.';
      }
    }

    String url = SERVER_DOMAIN + subUrl + "/" + userId + "/" + userHc;
    // String url =
    //     "http://10.0.2.2:8000/api/" + subUrl + "/" + userId + "/" + userHc;

    String urlArgs = "?" +
        (page == null ? "" : "page=" + page.toString()) +
        (limit == null ? "" : "&limit=" + limit.toString()) +
        (countryId == null ? "" : "&country_id=" + countryId.toString()) +
        (stateId == null ? "" : "&state_id=" + stateId.toString()) +
        (universityName == null ? "" : "&university_name=" + universityName) +
        (levelDegree == null ? "" : "&level[]=" + levelDegree) +
        (widget._keyword.isEmpty
            ? ""
            : "&major_name=" + widget._keyword.replaceAll(" ", "%20"));

    // insert cip if not empty
    String selectedCipParams = "";
    if (selectedCip.isNotEmpty) {
      var _cip = [];
      for (var i = 0; i < selectedCip.length; i++) {
        if (selectedCip[i] != null) {
          _cip = _cip + selectedCip[i];
        }
      }

      for (var i = 0; i < _cip.length; i++) {
        selectedCipParams = selectedCipParams + "&cip[]=" + _cip[i].toString();
      }
      urlArgs = urlArgs + selectedCipParams;
    }

    print(urlArgs);
    print('========= noted: get requestMap ' + "===== url " + url + urlArgs);

    try {
      loadingData = true;

      final client = new http.Client();
      final response = await client
          .get(
        Uri.parse(url + urlArgs),
        headers: headers,
      )
          .timeout(Duration(seconds: 60), onTimeout: () {
        throw 'Koneksi terputus. Silahkan coba lagi.';
      });

      if (response.statusCode == 200) {
        print('========= noted: get response body ' + response.body.toString());
        if (response.body.isNotEmpty) {
          // initial matchedFos, initial cip and initial bookmarkedList

          // parse majors
          var res = await json.decode(response.body);

          List jsonMajors;

          if (res.containsKey('data')) {
            jsonMajors = res['data']['majors'];
          } else {
            jsonMajors = [];
          }

          if (jsonMajors != null && jsonMajors.isNotEmpty) {
            for (var i = 0; i < jsonMajors.length; i++) {
              var id = jsonMajors[i]['major_id'];
              var check = jsonMajors[i]['is_checked'];
              print('majors: $i id: $id, check: $check');

              setState(() {
                if (jsonMajors[i]['level'] != null) {
                  _adviceList.list.add(new Advice(
                    universityLogo: jsonMajors[i]['university_logo'],
                    universityId: jsonMajors[i]['university_id'],
                    universityName: jsonMajors[i]['university_name'],
                    majorId: jsonMajors[i]['major_id'],
                    majorName: jsonMajors[i]['major_name'],
                    level: jsonMajors[i]['level'],
                    fos: jsonMajors[i]['fos'],
                    isChecked:
                        jsonMajors[i]['is_checked'] == "0" ? false : true,
                  ));
                }
              });
            }
          } else {
            _adviceList.list.clear();
          }

          if (jsonMajors.length < limit) {
            hasMore = false;
          } else {
            hasMore = true;
          }
          // setState(() {});

          String error = json.decode(response.body)['error'];
          if (error != null) {
            throw error;
          }
        } else {
          showOkAlertDialog(
            context: context,
            title: 'You need to do Questionnaire first!',
          );
        }
      } else {
        String error = json.decode(response.body)['error'];
        throw (error == '') ? 'Gagal memproses data' : error;
      }
      loadingData = false;
      setState(() {});
    } on SocketException {
      throw 'Tidak ada koneksi internet. Silahkan coba lagi.';
    }
  }

  Future<void> getBookmarkedMajors() async {
    var userId = await Global.instance.authId;
    var token = await Global.instance.apiToken;
    var userHc = await storage.read(key: 'authHc');

    // var type = "majors";
    String url = SERVER_DOMAIN + "wishlists-majors";

    print(token);
    print('========= noted: query all bookmarked item by HC = $userHc' +
        "===== url " +
        url);

    url = url + "?user_id=$userId&hc=$userHc";

    List _cip = [];

    _fosList.forEach((element) {
      _cip.add(element.cip);
    });

    print(userId);
    print(_cip);

    getCountry(_cip);

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'aplication/json',
        },
        body: jsonEncode({
          "user_id": userId,
          "cip": _cip,
        }));

    print(response.statusCode);
    print(response.body);
    print(response.request.headers);

    if (response.statusCode == 200) {
      List jsonMajors = await json.decode(response.body)['data']['data'];
      if (jsonMajors != null && jsonMajors.isNotEmpty) {
        for (var i = 0; i < jsonMajors.length; i++) {
          print('bookmarked_majors: $i');
          setState(() {
            // IF ITEM EXISTS DONT ADD TO BOOKMARK LIST
            // TODO: check res key value
            if (jsonMajors[i]['level'] != null) {
              _bookmarkedList.list.add(new Advice(
                universityLogo: jsonMajors[i]['picture'],
                universityId: jsonMajors[i]['detail_id'],
                universityName: jsonMajors[i]['detail_name'],
                majorId: jsonMajors[i]['entity_id'],
                majorName: jsonMajors[i]['name'],
                level: jsonMajors[i]['level'],
                fos: jsonMajors[i]['cip'],
                isChecked: true,
              ));
            }
          });
        }
      } else {
        _bookmarkedList.list.clear();
      }
    }
  }

  Future getLevel() async {
    final response = await http.get(
        Uri.parse(
            'https://primavisiglobalindo.net/unio/public/api/level_major'),
        // Send authorization headers to the backend.
        headers: {
          // HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'aplication/json',
        });
    print(response.body);

    levelRes = jsonDecode(response.body)['data'];

    for (var i = 0; i < levelRes.length; i++) {
      setState(() {
        level.add(levelRes[i]['name'].toString());
      });
    }

    if (Global.instance.authLevelId != null) {
      var selected = await levelRes.firstWhere(
          (element) => element['id'] == Global.instance.authLevelId,
          orElse: () => null);
      levelDegree = selected != null ? selected['name'] : null;
      showLevelDefault = true;
      levelDefault = true;
      levelDefaultValue = levelDegree;
    }

    print("level=" + levelDegree.toString());
  }

  Future getCountry(_cip) async {
    var token = await Global.instance.apiToken;
    final response =
        await http.post(Uri.parse(SERVER_DOMAIN + 'match-with-me/countries'),
            // Send authorization headers to the backend.
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $token',
              HttpHeaders.contentTypeHeader: 'aplication/json',
            },
            body: jsonEncode({"cip": _cip}));
    print('get ==== ' + SERVER_DOMAIN + 'match-with-ne/countries');
    print(response.body);
    setState(() {
      // _valCountry = null;
      countries.clear();
      countryList.clear();
      countryRes = jsonDecode(response.body)['data']['countries'];
    });
    // print(countryRes.toString());
    // state = [{"id":1,"name":"Jawa Barat"},{"id":2,"name":"Jawa Tengah"},{"id":3,"name":"Jawa Timur"},{"id":4,"name":"DKI Jakarta"}];
    countries.clear();
    for (var i = 0; i < countryRes.length; i++) {
      setState(() {
        countries.add(DropdownMenuItem(
          child: Text(countryRes[i]['country_name']),
          value: countryRes[i]['country_name'],
        ));
        countryList.add(countryRes[i]['country_name'].toString());
      });
    }

    if (Global.instance.authCountryId != null) {
      var selected = countryRes.firstWhere(
          (element) => element['country_id'] == Global.instance.authCountryId,
          orElse: () => null);
      setState(() {
        countryId = selected != null ? selected['country_id'] : null;
        _valCountry = selected != null ? selected['country_name'] : null;

        if (selected != null) {
          showCountryDefault = true;
          countryDefault = true;
          countryDefaultValue = _valCountry;
        }

        print(countryId);
      });
    }
  }

  void getState(String countryid) async {
    var token = await Global.instance.apiToken;
    final response = await http.get(
      Uri.parse(
          'https://primavisiglobalindo.net/unio/public/api/states?country_id=' +
              countryid),
      // Send authorization headers to the backend.
      headers: {HttpHeaders.authorizationHeader: token},
    );
    // print(response.body);
    setState(() {
      _valState = null;
      states.clear();
      stateList.clear();
      stateRes = jsonDecode(response.body)['data']['data'];
    });
    // print(stateRes.toString());
    // state = [{"id":1,"name":"Jawa Barat"},{"id":2,"name":"Jawa Tengah"},{"id":3,"name":"Jawa Timur"},{"id":4,"name":"DKI Jakarta"}];
    for (var i = 0; i < stateRes.length; i++) {
      setState(() {
        states.add(DropdownMenuItem(
          child: Text(stateRes[i]['name']),
          value: stateRes[i]['name'],
        ));
        stateList.add(stateRes[i]['name'].toString());
      });
    }
  }

  Future<void> addItemToBookmark(Advice entity) async {
    var userId = await Global.instance.authId;
    var token = await Global.instance.apiToken;
    var type = "majors";
    String url = SERVER_DOMAIN + "wishlists";

    print(token);
    print('========= noted: add item to bookmark ' + "===== url " + url);

    print(userId);
    print(type);
    print(entity.majorId);

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'aplication/json',
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": userId,
          "entity_type": type,
          "entity_id": entity.majorId,
        }));

    print(response.statusCode);
    print(response.body);

    // return response;
    if (response.statusCode != 200) {
      setState(() {
        entity.isChecked = !entity.isChecked;
      });
    }
  }

  Future<void> removeItemToBookmark(Advice entity) async {
    var userId = await Global.instance.authId;
    var token = await Global.instance.apiToken;
    var type = "majors";
    String url = SERVER_DOMAIN + "wishlists";

    print(token);
    print('========= noted: remove item to bookmark ' + "===== url " + url);

    print(userId);
    print(type);
    print(entity.majorId);

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'aplication/json',
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": userId,
          "entity_type": type,
          "entity_id": entity.majorId,
        }));

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200) {
      setState(() {
        // _adviceList.list.add(entity);
        entity.isChecked = !entity.isChecked;
      });
    }
  }

  Future<void> updateProfile({String field, bool isEmpty = false}) async {
    Map<String, String> headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    var url = SERVER_DOMAIN + 'users/' + Global.instance.authId;
    var token = Global.instance.apiToken;
    headers.addAll(
        <String, String>{HttpHeaders.authorizationHeader: 'Bearer $token'});
    print(url);
    print(headers);

    final client = new http.Client();

    if (field == 'country_id') {
      var _selectedCountryId = countryId;
      final response = await client.put(Uri.parse(url),
          headers: headers,
          body:
              jsonEncode({'country_id': !isEmpty ? _selectedCountryId : null}));
      print(response.body);

      // var msg = jsonDecode(response.body)['message'];

      if (response.statusCode == 200) {
        Global.instance.authCountryId = !isEmpty ? _selectedCountryId : null;

        // print(Global.instance.authCountryId);

        storage.write(
            key: 'authCountryId',
            value: !isEmpty ? _selectedCountryId.toString() : null);

        showOkAlertDialog(
            context: context,
            title: "User's search preference updated succesfuully");
      } else {
        showOkAlertDialog(context: context, title: 'Update not successful');
      }
    } else if (field == 'level_id') {
      var selected =
          levelRes.firstWhere((element) => element['name'] == levelDegree);
      int _selectedLevelId = selected['id'];
      final response = await client.put(Uri.parse(url),
          headers: headers,
          body: jsonEncode({'level_id': !isEmpty ? _selectedLevelId : null}));
      print(response.body);

      var msg = jsonDecode(response.body)['message'];

      if (response.statusCode == 200) {
        Global.instance.authLevelId = !isEmpty ? _selectedLevelId : null;

        // print(Global.instance.authCountryId);

        storage.write(
            key: 'authLevelId',
            value: !isEmpty ? _selectedLevelId.toString() : null);

        showOkAlertDialog(
            context: context,
            title: "User's search preference updated succesfuully");
      } else {
        showOkAlertDialog(context: context, title: 'Update not successful');
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamed('/Tabs', arguments: 2);
        return shouldPop;
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: DrawerWidget(),
          body: Stack(children: [
            CustomScrollView(controller: scrollController, slivers: <Widget>[
              SliverAppBar(
                // snap: true,
                // floating: true,
                automaticallyImplyLeading: false,
                leading: new IconButton(
                  icon: new Icon(UiIcons.return_icon,
                      color: Theme.of(context).primaryColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: <Widget>[
                  Container(
                      width: 30,
                      height: 30,
                      margin:
                          EdgeInsets.only(top: 12.5, bottom: 12.5, right: 20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(300),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('/Tabs', arguments: 1);
                        },
                      )),
                ],
                backgroundColor: widget._category.color,
                expandedHeight: 200,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                              widget._category.color,
                              Theme.of(context).primaryColor.withOpacity(0.5),
                            ])),
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Hero(
                              tag: widget._category.id,
                              child: new Icon(
                                widget._category.icon,
                                color: Theme.of(context).primaryColor,
                                size: 50,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              '${widget._category.name}',
                              style: Theme.of(context).textTheme.display3,
                            ),
                          ],
                        )),
                      ),
                      Positioned(
                        right: -60,
                        bottom: -100,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.05),
                            borderRadius: BorderRadius.circular(300),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        top: -80,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.09),
                            borderRadius: BorderRadius.circular(150),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SliverStickyHeader(
                header: Container(
                  color: Color(0xffFAFAFA),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: _mainSearchBar(),
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    (_bookmarkedList.list.isNotEmpty)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 20, right: 10),
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.star,
                                color: Theme.of(context).hintColor,
                              ),
                              title: Text(
                                'Bookmarked Items',
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.display1,
                              ),
                              subtitle: Text('Swipe items to unbookmark'),
                              trailing: IconButton(
                                icon: Icon(
                                  _bookmarkExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Theme.of(context).hintColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _bookmarkExpanded =
                                        _bookmarkExpanded ? false : true;
                                  });
                                },
                              ),
                            ),
                          )
                        : SizedBox(),
                    // (_bookmarkExpanded)
                    //     ? Container(
                    //         child: ListView.separated(
                    //           scrollDirection: Axis.vertical,
                    //           shrinkWrap: true,
                    //           primary: false,
                    //           itemCount: _bookmarkedList.list.length,
                    //           separatorBuilder: (context, index) {
                    //             return SizedBox(height: 10);
                    //           },
                    //           itemBuilder: (context, index) {
                    //             if (_bookmarkedList.list.isNotEmpty) {
                    //               return AdviceListItemWidget(
                    //                 heroTag: 'bookmark_list',
                    //                 advice:
                    //                     _bookmarkedList.list.elementAt(index),
                    //                 onBookmarked: () {
                    //                   setState(() {
                    //                     Advice bmItem = _bookmarkedList.list
                    //                         .elementAt(index);
                    //                     bmItem.isChecked = false;

                    //                     // _adviceList.list.add(bmItem);
                    //                     removeItemToBookmark(bmItem);

                    //                     _bookmarkedList.list.removeAt(index);
                    //                   });
                    //                 },
                    //               );
                    //             } else {
                    //               return Text('no bookmarked item');
                    //             }
                    //           },
                    //         ),
                    //       )
                    //     : SizedBox(),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 10),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          UiIcons.box,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          '${widget._category.name} Items',
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.display1,
                        ),
                        // subtitle: Text('Swipe items to bookmark'),
                      ),
                    ),
                    Container(
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: _adviceList.list.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10);
                        },
                        itemBuilder: (context, index) {
                          if (_adviceList.list.isNotEmpty) {
                            return AdviceListItemWidget(
                              heroTag: 'advice_list',
                              advice: _adviceList.list.elementAt(index),
                              dismissibleColor: Colors.amber,
                              dismissibleIcon: Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                              onBookmarked: () {
                                setState(() {
                                  // add bookmark
                                  Advice bmItem =
                                      _adviceList.list.elementAt(index);

                                  setState(() {
                                    bmItem.isChecked = !bmItem.isChecked;
                                  });

                                  // _bookmarkedList.list.add(bmItem);
                                  addItemToBookmark(bmItem);
                                  showOkAlertDialog(
                                      context: context,
                                      title: bmItem.isChecked
                                          ? 'Successfully Bookmarked'
                                          : 'Successfully Unbookmarked');

                                  // _adviceList.list.removeAt(index);
                                });
                              },
                            );
                          } else {
                            return Text('no bookmarked item');
                          }
                        },
                      ),
                    ),
                    (hasMore)
                        ? Center(
                            // optional
                            child: CircularProgressIndicator(),
                          )
                        : Container(),
                  ]),
                ),
              ),
            ]),
            isRightDrawerOpen
                ? GestureDetector(
                    onTap: () {
                      closeRightDrawer();
                    },
                    child: Container(color: Colors.black45),
                  )
                : SizedBox(),
            _rightDrawer(),
          ]),
        ),
      ),
    );
  }

  Widget _rightDrawer() {
    return AnimatedContainer(
      transform: Matrix4.translationValues(xOffset, yOffset, 0),
      duration: Duration(milliseconds: 250),
      child: Container(
        width: xOffset * 3,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        padding: EdgeInsets.only(top: 20, left: 15.0, right: 15.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.display1,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: Container(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                        onTap: () {
                          closeRightDrawer();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Theme.of(context).hintColor,
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 0),
                children: <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: searchUniversityName(),
                      ),
                      CustomDropdownWidget(
                          context: context,
                          hint: 'Country',
                          selectedItem: _valCountry,
                          items: countryList,
                          onChanged: (value) {
                            setState(() {
                              _valCountry = value;
                              if (value != null) {
                                print("nilai=" + value.toString());
                                var selected = countryRes.firstWhere(
                                    (element) =>
                                        element['country_name'] == value);
                                _valCountryId =
                                    selected['country_id'].toString();
                                _valState = '';
                                getState(selected['country_id'].toString());
                                countryId = selected['country_id'];

                                showCountryDefault = true;
                              } else {
                                countryId = null;
                                stateId = null;

                                showCountryDefault = false;
                              }

                              if (countryDefaultValue == _valCountry) {
                                countryDefault = true;
                              } else {
                                countryDefault = false;
                              }
                            });
                          }),
                      Visibility(
                        visible: (showCountryDefault) ? true : false,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Make Country as default'),
                              Checkbox(
                                  value: countryDefault,
                                  onChanged: (bool value) {
                                    setState(() {
                                      countryDefault = value;
                                      if (countryDefault) {
                                        countryDefaultValue = _valCountry;
                                        updateProfile(field: 'country_id');
                                      } else {
                                        countryDefaultValue = '';
                                        updateProfile(
                                            field: 'country_id', isEmpty: true);
                                      }
                                    });
                                  })
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // CustomDropdownWidget(
                      //   context: context,
                      //   hint: 'State',
                      //   selectedItem: _valState,
                      //   items: stateList,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       if (value != null) {
                      //         var selected = stateRes.firstWhere(
                      //             (element) => element['name'] == value);

                      //         stateId = selected['id'];
                      //       } else {
                      //         stateId = null;
                      //       }
                      //     });
                      //   },
                      // ),
                      CustomDropdownWidget(
                        context: context,
                        hint: 'Level',
                        selectedItem: levelDegree,
                        items: level,
                        onChanged: (value) {
                          setState(() {
                            levelDegree = value;

                            if (value != null) {
                              showLevelDefault = true;
                            } else {
                              showLevelDefault = false;
                            }

                            if (levelDefaultValue == levelDegree) {
                              levelDefault = true;
                            } else {
                              levelDefault = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  Visibility(
                    visible: (showLevelDefault) ? true : false,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Make Level as default'),
                          Checkbox(
                              value: levelDefault,
                              onChanged: (bool value) {
                                setState(() {
                                  levelDefault = value;
                                  if (levelDefault) {
                                    levelDefaultValue = levelDegree;
                                    updateProfile(field: 'level_id');
                                  } else {
                                    levelDefaultValue = '';
                                    updateProfile(
                                        field: 'level_id', isEmpty: true);
                                  }
                                });
                              })
                        ],
                      ),
                    ),
                  ),
                  // ),
                  (_fosList.isNotEmpty) ? _checkBoxes() : SizedBox(),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // close window
                      closeRightDrawer();

                      // search with filter
                      _adviceList.list.clear();
                      page = 1;
                      hasMore = true;
                      setState(() {});
                      getData();
                    },
                    child: Text('Apply'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainSearchBar() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).hintColor.withOpacity(0.10),
              offset: Offset(0, 4),
              blurRadius: 10)
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: TextFormField(
              // initialValue: widget._keyword,
              keyboardType: TextInputType.text,
              controller: myController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(12),
                hintText: 'Search Major Name',
                hintStyle: TextStyle(
                    color: Theme.of(context).focusColor.withOpacity(0.8)),
                border: UnderlineInputBorder(borderSide: BorderSide.none),
                enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
          (myController.text.isNotEmpty)
              ? Expanded(
                  flex: 1,
                  child: IconButton(
                    padding: EdgeInsets.only(left: 0.0),
                    onPressed: () {
                      setState(() {
                        myController.clear();
                      });
                    },
                    icon: Icon(UiIcons.trash_1,
                        size: 20,
                        color: Theme.of(context).hintColor.withOpacity(0.5)),
                  ))
              : SizedBox(),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {
                openRightDrawer();
              },
              icon: Icon(UiIcons.filter,
                  size: 20,
                  color: Theme.of(context).hintColor.withOpacity(0.5)),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {
                _adviceList.list.clear();
                hasMore = true;
                page = 1;
                setState(() {});
                getData();
              },
              icon: Icon(UiIcons.loupe,
                  size: 20,
                  color: Theme.of(context).hintColor.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchUniversityName() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).hintColor.withOpacity(0.10),
              offset: Offset(0, 4),
              blurRadius: 10)
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: TextFormField(
              // initialValue: widget._keyword,
              keyboardType: TextInputType.text,
              controller: univeristyNameSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(12),
                hintText: 'University Name',
                hintStyle: TextStyle(
                    color: Theme.of(context).focusColor.withOpacity(0.8)),
                border: UnderlineInputBorder(borderSide: BorderSide.none),
                enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
          (univeristyNameSearchController.text.isNotEmpty)
              ? Expanded(
                  flex: 2,
                  child: IconButton(
                    padding: EdgeInsets.only(left: 0.0),
                    onPressed: () {
                      setState(() {
                        univeristyNameSearchController.clear();
                      });
                    },
                    icon: Icon(UiIcons.trash_1,
                        size: 20,
                        color: Theme.of(context).hintColor.withOpacity(0.5)),
                  ))
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _checkBoxes() {
    List<Widget> checkBoxes = [];
    for (var i = 0; i < _fosList.length; i++) {
      checkBoxes.add(CheckboxListTile(
          title: Text(_fosList[i].name),
          value: _fosList[i].isChecked,
          onChanged: (value) {
            setState(() {
              // rebuild checkbox
              _fosList[i].isChecked = value;

              if (value) {
                selectedCip[i] = _fosList[i].cip;
              } else {
                selectedCip[i] = null;
              }
            });
          }));
    }

    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Field of Study Classification'),
              ),
              Checkbox(
                value: _fosListSelectAll,
                onChanged: (value) {
                  setState(() {
                    _fosListSelectAll = value;
                    if (value) {
                      for (var i = 0; i < _fosList.length; i++) {
                        _fosList[i].isChecked = value;
                        selectedCip[i] = _fosList[i].cip;
                      }
                    } else {
                      for (var i = 0; i < _fosList.length; i++) {
                        _fosList[i].isChecked = value;
                        selectedCip[i] = null;
                      }
                    }
                  });
                },
              ),
            ],
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 250,
              minHeight: 100,
            ),
            child: ListView(shrinkWrap: true, children: <Widget>[
              ...checkBoxes,
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _showNeedLoginAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You are not logged in!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you wanna login first?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pushNamed('/SignIn');
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
