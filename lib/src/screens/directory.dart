import 'package:Unio/src/screens/compare/compare.dart';
import 'package:Unio/src/utilities/global.dart';
import 'package:Unio/src/widgets/CustomDropdownSearchWidget.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/ui_icons.dart';
import '../models/category.dart';
import '../models/route_argument.dart';
import '../widgets/DrawerWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'dart:convert';
import 'dart:io';
import '../models/utilities.dart';

// ignore: must_be_immutable
class DirectoryWidget extends StatefulWidget {
  RouteArgument routeArgument;
  Category _category;
  String _keyword;
  int panjangarg;
  String _countryid;
  String _stateid;
  String _uniid;
  String filterCountry = '';
  String filterState = '';
  String filterCountryValue = '';
  String filterStateValue = '';

  DirectoryWidget({Key key, this.routeArgument}) {
    _category = this.routeArgument.argumentsList[0] as Category;
    _keyword = this.routeArgument.argumentsList[1] as String;
    panjangarg = this.routeArgument.argumentsList.length;
    print("panjang=" + panjangarg.toString());
    if (panjangarg > 2) {
      _countryid = this.routeArgument.argumentsList[2];
      _stateid = this.routeArgument.argumentsList[3];
      filterCountryValue = this.routeArgument.argumentsList[4];
      filterStateValue = this.routeArgument.argumentsList[5];
      if (panjangarg > 7) {
        _uniid = this.routeArgument.argumentsList[4] as String;
      }
    }
  }

  @override
  _DirectoryWidgetState createState() => _DirectoryWidgetState();
}

class _DirectoryWidgetState extends State<DirectoryWidget> {
  final myController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  bool hasMore = true;
  int page = 1;
  String subUrl = '';
  String entity = '';

  double r_xOffset;
  double r_yOffset;

  double b_xOffset;
  double b_yOffset;

  bool isRightDrawerOpen;
  bool isBottomDrawerOpen;

  Map compareMap = new Map();

  List<dynamic> directoryList = [];

  DropdownSearch<String> stateDropDown;
  DropdownSearch<String> countryDropDown;

  List<DropdownMenuItem> countries = [];
  List<DropdownMenuItem> states = [];

  List<String> countryList = [];
  List<String> stateList = [];

  var countryRes = List();
  var stateRes = List();

  String _valCountry;
  String _valCountryId;

  String _valState;

  @override
  void initState() {
    setParam();
    getData();

    getCountry();

    r_xOffset = 500;
    r_yOffset = 0;

    b_xOffset = 500;
    b_yOffset = 0;

    isRightDrawerOpen = false;
    isBottomDrawerOpen = false;

    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        print('============ _scrollListener end end ' +
            hasMore.toString() +
            '======' +
            page.toString());
        if (hasMore) {
          getData();
        }
      }
    });

    print(widget._stateid);
    // print(widget.filterState);
    // print(widget.filterStateValue);

    if (widget._countryid != null) {
      setInitialValCountry(widget._countryid);
    }

    if (widget._countryid != null && widget._stateid != null) {
      // print('pass');
      setInitialValState(widget._countryid, widget._stateid);
      // getstate(widget._stateid);
    }
  }

  void setInitialValCountry(String countryid) async {
    final response = await http.get(
      Uri.parse('https://primavisiglobalindo.net/unio/public/api/countries'),
    );
    // print(response.body);
    var data = await jsonDecode(response.body)['data'];

    countryRes = data;

    // print(countryRes.toString());
    // state = [{"id":1,"name":"Jawa Barat"},{"id":2,"name":"Jawa Tengah"},{"id":3,"name":"Jawa Timur"},{"id":4,"name":"DKI Jakarta"}];
    countries.clear();
    for (var i = 0; i < countryRes.length; i++) {
      setState(() {
        countries.add(DropdownMenuItem(
          child: Text(countryRes[i]['name']),
          value: countryRes[i]['name'],
        ));

        countryList.add(countryRes[i]['name'].toString());
      });
    }

    var selected = await data
        .firstWhere((element) => element['id'] == int.parse(countryid));
    _valCountry = selected['name'];
    print(_valCountry);
  }

  void setInitialValState(String countryid, String stateid) async {
    // getstate(widget._stateid);
    // print(countryid);
    final response = await http.get(
      Uri.parse(
          'https://primavisiglobalindo.net/unio/public/api/states?country_id=' +
              countryid),
      // Send authorization headers to the backend.
    );
    // print(response.body);
    var data = await jsonDecode(response.body)['data']['data'];

    stateRes = data;

    print(stateRes.toString());
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

    var selected =
        await data.firstWhere((element) => element['id'] == int.parse(stateid));

    _valState = selected['name'];
    print('_valState : $_valState');
  }

  void setParam() {
    directoryList.clear();
    // widget._category.utilities.clear();

    switch (widget._category.name) {
      case 'University':
        subUrl = 'universities';
        entity = 'universities';
        break;
      case 'Field of study':
        subUrl = 'university-majors';
        entity = 'majors';
        break;
      case 'Vendor':
        subUrl = 'vendors';
        entity = 'vendors';
        break;
      case 'Places to Live':
        subUrl = 'placetolive';
        entity = 'place-to-lives';
        break;
      case 'Scholarship':
        subUrl = 'scholarship';
        entity = 'scholarships';
        break;
      case 'Article':
        subUrl = 'articles';
        entity = 'articles';
        break;
      default:
        subUrl = 'universities';
        entity = 'universities';
        break;
    }
  }

  void getData() async {
    setState(() {});
    String url;
    var userId = Global.instance.authId != null ? Global.instance.authId : '';

    if (widget._countryid == 'null' || widget._countryid == null) {
      // ignore: unnecessary_statements
      widget._countryid == '';
    } else {
      widget.filterCountry = widget._countryid;
    }

    if (widget._stateid == 'null' || widget._stateid == null) {
      // ignore: unnecessary_statements
      widget._stateid == '';
    } else {
      widget.filterState = widget._stateid;
    }

    print(widget.filterCountry);
    print(widget.filterState);

    print(subUrl);

    if (widget.panjangarg > 7) {
      url = SERVER_DOMAIN +
                  "search?keyword=universities" +
                  '&country=' +
                  widget._countryid ==
              'null'
          ? ''
          : widget._countryid + '&state=' + widget._stateid + '&page=$page';
      if (widget.panjangarg == 5) {
        url =
            SERVER_DOMAIN + "search?keyword=university-majors/" + widget._uniid;
      }
    } else {
      url = SERVER_DOMAIN +
          'search?keyword=' +
          subUrl +
          '&user_id=' +
          userId +
          '&name=' +
          widget._keyword +
          '&country=' +
          widget.filterCountry +
          '&state=' +
          widget.filterState +
          '&page=$page';

      // '&university=' + '';
      // '&level=' + '';
      print('========= noted: get requestMap ' + "===== url " + url);
    }
    print(url);
    print('lala');
    try {
      final client = new http.Client();
      final response = await client
          .get(
        Uri.parse(url),
      )
          .timeout(Duration(seconds: 60), onTimeout: () {
        throw 'Koneksi terputus. Silahkan coba lagi.';
      });

      if (response.statusCode == 200) {
        print('========= noted: get response body ' + response.body.toString());
        if (response.body.isNotEmpty) {
          dynamic jsonMap;
          // if (widget.panjangarg > 2) {
          //   jsonMap = json.decode(response.body)['data']['data'];
          // } else {
          jsonMap = json.decode(response.body)['data'];
          // }

          if (jsonMap != null) {
            // print(jsonMap[0]['is_checked']);
            for (var i = 0; i < jsonMap.length; i++) {
              dynamic jsonUniv;
              if (widget._category.name == 'Field of study' ||
                  widget._category.name == 'Scholarship') {
                //university, name
                jsonUniv = jsonMap[i]['university'];
              }

              // add isBookmarked bool
              // print(jsonMap[i]);

              jsonMap[i]['is_checked'] == null
                  ? jsonMap[i]['isBookmarked'] = false
                  : jsonMap[i]['isBookmarked'] = true;

              // if (jsonMap[i]['is_checked'] == null) {
              //   print(jsonMap[i]['is_checked']);
              //   jsonMap[i]['isBookmarked'] = false;
              //   print(jsonMap[i]['isBookmarked']);
              // } else {
              //   print(jsonMap[i]['is_checked']);
              //   jsonMap[i]['isBookmarked'] = true;
              // }

              // add isCompared bool
              jsonMap[i]['isCompared'] = false;

              directoryList.add(jsonMap[i]);

              // widget._category.utilities.add(new Utilitie(
              //     jsonMap[i][(widget._category.name == 'Article')
              //             ? 'title'
              //             : 'name']
              //         .toString(),
              //     jsonMap[i]['header_src'].toString(),
              //     (jsonUniv != null)
              //         ? jsonUniv['logo_src'].toString()
              //         : jsonMap[i][(widget._category.name == 'Vendor')
              //                 ? 'logo'
              //                 : ((widget._category.name == 'Article' ||
              //                         widget._category.name == 'Places to Live')
              //                     ? 'picture'
              //                     : 'logo_src')]
              //             .toString(), //seharusnya type
              //     (jsonUniv != null)
              //         ? jsonUniv['name'].toString()
              //         : jsonMap[i]['description'].toString(),
              //     jsonMap[i]['website'].toString(),
              //     jsonMap[i][
              //         'id'], //seharusnya available gak ada response param ini, jadi value default
              //     (jsonUniv != null)
              //         ? 1
              //         : 0, //seharusnya price, tapi buat ngcek, ada univ name ato gak
              //     0, //rate
              //     0 //discount
              //     ));
            }
          }

          int currentPage;
          int lastPage;

          if (widget.panjangarg > 6) {
            currentPage = json.decode(response.body)['meta']['current_page'];
            lastPage = json.decode(response.body)['meta']['last_page'];
          } else {
            currentPage = json.decode(response.body)['meta']['current_page'];
            lastPage = json.decode(response.body)['meta']['last_page'];
          }

          if (currentPage < lastPage) {
            page++;
            hasMore = true;
          } else {
            hasMore = false;
          }
          setState(() {});

          String error = json.decode(response.body)['error'];
          if (error != null) {
            throw error;
          }
        }
      } else {
        String error = json.decode(response.body)['error'];
        throw (error == '') ? 'Gagal memproses data' : error;
      }
    } on SocketException {
      throw 'Tidak ada koneksi internet. Silahkan coba lagi.';
    }
  }

  void getCountry() async {
    final response = await http.get(
      Uri.parse('https://primavisiglobalindo.net/unio/public/api/countries'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            "VsNYL8JE4Cstf8gb9LYCobuxYWzIo71bvUkIVYXXVUO4RtvuRxGYxa3TFzsaOeHxxf4PRY7MIhBPJBly4H9bckY5Qr44msAxc0l4"
      },
    );
    // print(response.body);
    setState(() {
      // _valCountry = null;
      countries.clear();
      countryList.clear();
      countryRes = jsonDecode(response.body)['data'];
    });
    // print(countryRes.toString());
    // state = [{"id":1,"name":"Jawa Barat"},{"id":2,"name":"Jawa Tengah"},{"id":3,"name":"Jawa Timur"},{"id":4,"name":"DKI Jakarta"}];
    countries.clear();
    for (var i = 0; i < countryRes.length; i++) {
      setState(() {
        countries.add(DropdownMenuItem(
          child: Text(countryRes[i]['name']),
          value: countryRes[i]['name'],
        ));
        countryList.add(countryRes[i]['name'].toString());
      });
    }
  }

  void getstate(String countryid) async {
    final response = await http.get(
      Uri.parse(
          'https://primavisiglobalindo.net/unio/public/api/states?country_id=' +
              countryid),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            "VsNYL8JE4Cstf8gb9LYCobuxYWzIo71bvUkIVYXXVUO4RtvuRxGYxa3TFzsaOeHxxf4PRY7MIhBPJBly4H9bckY5Qr44msAxc0l4"
      },
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

  void openRightDrawer() {
    setState(() {
      isRightDrawerOpen = true;
      r_xOffset = MediaQuery.of(context).size.width * 1 / 6;
    });
  }

  void closeRightDrawer() {
    setState(() {
      isRightDrawerOpen = false;
      r_xOffset = MediaQuery.of(context).size.width;
    });
  }

  void openBottomDrawer() {
    setState(() {
      isBottomDrawerOpen = true;
      b_xOffset = MediaQuery.of(context).size.width * 1 / 4;
    });
  }

  void closeBottomDrawer() {
    setState(() {
      isBottomDrawerOpen = false;
      b_xOffset = MediaQuery.of(context).size.width;
    });
  }

  Future<void> addBookmark(_id, _type, _item) async {
    Map<String, String> headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    var url = SERVER_DOMAIN + 'wishlists';
    var token = Global.instance.apiToken;
    headers.addAll(
        <String, String>{HttpHeaders.authorizationHeader: 'Bearer $token'});
    print(url);
    print(headers);

    final client = new http.Client();
    final response = await client.post(Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'user_id': Global.instance.authId,
          'entity_id': _id,
          'entity_type': _type,
        }));
    print(response.body);

    var data = json.decode(response.body);

    if (!data['success'])
      return Future(() {
        // var data = json.decode(response.body);
        showOkAlertDialog(
          context: context,
          title: 'Error: ' + data['message'],
        );
        setState(() {
          _item['isBookmarked'] = !_item['isBookmarked'];
        });
      });

    if (response.statusCode != 200)
      return Future(() {
        // var data = json.decode(response.body);
        showOkAlertDialog(
          context: context,
          title: "There is an error",
        );
        setState(() {
          _item['isBookmarked'] = !_item['isBookmarked'];
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      drawer: DrawerWidget(),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomScrollView(controller: scrollController, slivers: <Widget>[
            SliverAppBar(
              snap: true,
              floating: true,
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
                    margin: EdgeInsets.only(top: 12.5, bottom: 12.5, right: 20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(300),
                      onTap: () {
                        Navigator.of(context).pushNamed('/Tabs', arguments: 1);
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.05),
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.09),
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
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    //child: SearchBarWidget(),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.10),
                              offset: Offset(0, 4),
                              blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            alignment: Alignment.centerRight,
                            children: <Widget>[
                              TextFormField(
                                initialValue: widget._keyword,
                                keyboardType: TextInputType.text,
                                onChanged: (input) => myController.text = input,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(12),
                                  hintText: 'Search',
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.8)),
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide.none),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                              ),
                              (entity == 'universities' || entity == 'majors')
                                  ? Positioned(
                                      right: 30.0,
                                      child: IconButton(
                                        onPressed: () {
                                          openRightDrawer();
                                        },
                                        icon: Icon(UiIcons.filter,
                                            size: 20,
                                            color: Theme.of(context)
                                                .hintColor
                                                .withOpacity(0.5)),
                                      ),
                                    )
                                  : SizedBox(),
                              IconButton(
                                onPressed: () {
                                  /*Navigator.of(context).pushNamed('/Directory',
                                      arguments: new RouteArgument(argumentsList: [
                                        widget._category,
                                        myController.text
                                      ]));*/
                                  widget._keyword = myController.text;
                                  page = 1;
                                  directoryList.clear();
                                  // widget._category.utilities.clear();
                                  setState(() {});
                                  getData();
                                },
                                icon: Icon(UiIcons.loupe,
                                    size: 20,
                                    color: Theme.of(context)
                                        .hintColor
                                        .withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
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
                    ),
                  ),
                  Container(
                      // padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10);
                    },
                    itemCount: directoryList.length,
                    // itemCount: widget._category.utilities.length,
                    itemBuilder: (BuildContext context, int index) {
                      var item = directoryList[index];
                      var title =
                          (item['name'] != null) ? item['name'] : item['title'];
                      Widget subtitle;
                      var imgSrc;
                      var trailing;

                      switch (widget._category.name) {
                        case 'University':
                          imgSrc = item['logo_src'];
                          var text = '';
                          List<dynamic> rank =
                              item['rank'] != null ? item['rank'] : [];
                          if (rank.length > 0) {
                            for (var i = 0; i < rank.length; i++) {
                              text = text +
                                  rank[i]['rank'] +
                                  ' ' +
                                  rank[i]['name'] +
                                  ' ';
                            }
                          }
                          subtitle = Row(
                            children: [
                              (text != '')
                                  ? FaIcon(
                                      FontAwesomeIcons.trophy,
                                      size: 12.0,
                                      color: Color(0xFFF2C76E),
                                    )
                                  : SizedBox(),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  text,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );

                          trailing = Container(
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (Global.instance.apiToken != null) {
                                      addBookmark(
                                          item['id'], 'universities', item);
                                      setState(() {
                                        item['isBookmarked'] =
                                            !item['isBookmarked'];
                                      });
                                      showOkAlertDialog(
                                          context: context,
                                          title: item['isBookmarked']
                                              ? 'Successfully Bookmarked'
                                              : 'Successfully Unbookmarked');
                                    } else {
                                      _showNeedLoginAlert(context);
                                    }
                                  },
                                  child: (item['isBookmarked'])
                                      ? Icon(FontAwesomeIcons.solidHeart,
                                          color: Color(0xFFDC3545))
                                      : Icon(FontAwesomeIcons.heart,
                                          color: Color(0xFFDC3545)),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      // openBottomDrawer();
                                      if (item['isCompared']) {
                                        setState(() {
                                          compareMap
                                              .remove(item['id'].toString());
                                          item['isCompared'] =
                                              !item['isCompared'];
                                        });
                                      } else {
                                        if (compareMap.length < 2) {
                                          setState(() {
                                            compareMap[item['id'].toString()] =
                                                item;
                                            item['isCompared'] =
                                                !item['isCompared'];
                                          });
                                        }
                                      }
                                    },
                                    child: (item['isCompared'])
                                        ? Icon(FontAwesomeIcons.solidClone,
                                            color: Color(0xFFB9D174))
                                        : Icon(FontAwesomeIcons.clone,
                                            color: Color(0xFFB9D174))),
                              ]));
                          break;

                        case 'Field of study':
                          imgSrc = item['university']['logo_src'];
                          subtitle = Column(children: <Widget>[
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.graduationCap,
                                  size: 14.0,
                                  color: Color(0xFF5D9EDE),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    item['level'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.university,
                                  size: 12.0,
                                  color: Color(0xFF5D9EDE),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    item['university']['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ]);

                          trailing = Container(
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (Global.instance.apiToken != null) {
                                      addBookmark(item['id'], 'majors', item);
                                      setState(() {
                                        item['isBookmarked'] =
                                            !item['isBookmarked'];
                                      });
                                      showOkAlertDialog(
                                          context: context,
                                          title: item['isBookmarked']
                                              ? 'Successfully Bookmarked'
                                              : 'Successfully Unbookmarked');
                                    } else {
                                      _showNeedLoginAlert(context);
                                    }
                                  },
                                  child: (item['isBookmarked'])
                                      ? Icon(FontAwesomeIcons.solidHeart,
                                          color: Color(0xFFDC3545))
                                      : Icon(FontAwesomeIcons.heart,
                                          color: Color(0xFFDC3545)),
                                ),
                              ]));
                          break;

                        case 'Vendor':
                          imgSrc = item['logo_src'];
                          trailing = Container(
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (Global.instance.apiToken != null) {
                                      addBookmark(item['id'], 'vendors', item);
                                      setState(() {
                                        item['isBookmarked'] =
                                            !item['isBookmarked'];
                                      });
                                      showOkAlertDialog(
                                          context: context,
                                          title: item['isBookmarked']
                                              ? 'Successfully Bookmarked'
                                              : 'Successfully Unbookmarked');
                                    } else {
                                      _showNeedLoginAlert(context);
                                    }
                                  },
                                  child: (item['isBookmarked'])
                                      ? Icon(FontAwesomeIcons.solidHeart,
                                          color: Color(0xFFDC3545))
                                      : Icon(FontAwesomeIcons.heart,
                                          color: Color(0xFFDC3545)),
                                ),
                              ]));
                          break;

                        case 'Places to Live':
                          imgSrc = item['header_src'];
                          subtitle = Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.mapMarkerAlt,
                                size: 12.0,
                                color: Color(0xFFDC3545),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  item['address'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                          trailing = Container(
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (Global.instance.apiToken != null) {
                                      addBookmark(
                                          item['id'], 'place_lives', item);
                                      setState(() {
                                        item['isBookmarked'] =
                                            !item['isBookmarked'];
                                      });
                                      showOkAlertDialog(
                                          context: context,
                                          title: item['isBookmarked']
                                              ? 'Successfully Bookmarked'
                                              : 'Successfully Unbookmarked');
                                    } else {
                                      _showNeedLoginAlert(context);
                                    }
                                  },
                                  child: (item['isBookmarked'])
                                      ? Icon(FontAwesomeIcons.solidHeart,
                                          color: Color(0xFFDC3545))
                                      : Icon(FontAwesomeIcons.heart,
                                          color: Color(0xFFDC3545)),
                                ),
                              ]));
                          break;

                        case 'Scholarship':
                          if (item['university'] != null) {
                            imgSrc = item['university']['logo_src'];
                            subtitle = Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.university,
                                  size: 12.0,
                                  color: Color(0xFF5D9EDE),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    item['university']['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }
                          break;

                        case 'Article':
                          imgSrc = item['picture'];
                          break;

                        default:
                          break;
                      }

                      return InkWell(
                        highlightColor: Colors.transparent,
                        splashColor:
                            Theme.of(context).accentColor.withOpacity(0.08),
                        onTap: () {
                          print(entity);
                          print(directoryList[index]);

                          Navigator.of(context).pushNamed('/Detail',
                              arguments: RouteArgument(
                                  param1: [directoryList[index]['id'], entity],
                                  // param1:
                                  // widget._category.utilities[index].available,
                                  param2: () {
                                    // if (Global.instance.apiToken != null) {
                                    //   addBookmark(
                                    //       item['id'], 'universities', item);
                                    setState(() {
                                      item['isBookmarked'] =
                                          !item['isBookmarked'];
                                    });
                                    // } else {
                                    //   _showNeedLoginAlert(context);
                                    // }
                                  }));
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(
                            border:
                                (directoryList[index]['is_sponsored'] != null)
                                    ? Border.all(color: Colors.yellow)
                                    : null,
                            // borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                // spreadRadius: 1,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 0), // changes position of shadow
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: (imgSrc == null)
                                ? Image.asset(
                                    'img/icon_campus.jpg',
                                  )
                                : Hero(
                                    tag: title + ' logo ' + index.toString(),
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        image: DecorationImage(
                                            image: NetworkImage(imgSrc),
                                            fit: BoxFit.contain),
                                      ),
                                    ),
                                  ),
                            title: Wrap(
                                spacing: (directoryList[index]
                                            ['is_sponsored'] !=
                                        null)
                                    ? 5
                                    : 0,
                                crossAxisAlignment: WrapCrossAlignment.end,
                                children: [
                                  (directoryList[index]['is_sponsored'] != null)
                                      ? Icon(FontAwesomeIcons.ad,
                                          color: Colors.yellow)
                                      : SizedBox(),
                                  Text(
                                    title,
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ]),
                            subtitle: Wrap(children: [
                              subtitle != null ? subtitle : SizedBox(),
                              (directoryList[index]['is_sponsored'] != null)
                                  ? Text('In Partnership with UNIO')
                                  : SizedBox(),
                            ]),
                            trailing: trailing,
                          ),
                        ),
                      );
                    },
                  )
                      // new StaggeredGridView.countBuilder(
                      //   primary: false,
                      //   shrinkWrap: true,
                      //   crossAxisCount: 4,
                      //   itemCount: widget._category.utilities.length,
                      //   itemBuilder: (BuildContext context, int index) {
                      //     return InkWell(
                      //       highlightColor: Colors.transparent,
                      //       splashColor:
                      //           Theme.of(context).accentColor.withOpacity(0.08),
                      //       onTap: () {
                      //         print(entity);
                      //         print(widget._category.utilities[index].available);
                      //         Navigator.of(context).pushNamed('/Detail',
                      //             arguments: RouteArgument(
                      //                 param1: widget
                      //                     ._category.utilities[index].available,
                      //                 param2: entity));
                      //       },
                      //       child: Container(
                      //         decoration: BoxDecoration(
                      //           color: Theme.of(context).primaryColor,
                      //           borderRadius: BorderRadius.circular(6),
                      //           boxShadow: [
                      //             BoxShadow(
                      //                 color: Theme.of(context)
                      //                     .hintColor
                      //                     .withOpacity(0.10),
                      //                 offset: Offset(0, 4),
                      //                 blurRadius: 10)
                      //           ],
                      //         ),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: <Widget>[
                      //             (widget._category.utilities[index].type == 'null')
                      //                 ? Image.asset('img/icon_campus.jpg')
                      //                 : Image.network(
                      //                     widget._category.utilities[index].type),
                      //             SizedBox(height: 12),
                      //             Padding(
                      //               padding: const EdgeInsets.symmetric(
                      //                   horizontal: 15, vertical: 5),
                      //               child: Column(
                      //                 mainAxisAlignment: MainAxisAlignment.start,
                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                      //                 children: [
                      //                   Text(
                      //                     widget._category.utilities[index].name,
                      //                     style: Theme.of(context).textTheme.body2,
                      //                   ),
                      //                   (widget._category.utilities[index].price ==
                      //                           1)
                      //                       ? Text(
                      //                           widget._category.utilities[index]
                      //                               .description,
                      //                           style: Theme.of(context)
                      //                               .textTheme
                      //                               .body1,
                      //                         )
                      //                       : Container(),
                      //                 ],
                      //               ),
                      //             ),
                      //             SizedBox(height: 15),
                      //           ],
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   staggeredTileBuilder: (int index) =>
                      //       new StaggeredTile.fit(2),
                      //   mainAxisSpacing: 15.0,
                      //   crossAxisSpacing: 15.0,
                      // ),
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
          (isRightDrawerOpen)
              ? GestureDetector(
                  onTap: () {
                    closeRightDrawer();
                  },
                  child: Container(color: Colors.black45),
                )
              : SizedBox(),
          _rightDrawer(),
          (compareMap.isNotEmpty)
              ? Positioned(
                  bottom: 10,
                  child: ElevatedButton(
                    style: (compareMap.length == 1)
                        ? ElevatedButton.styleFrom(
                            primary:
                                Theme.of(context).hintColor.withOpacity(0.5))
                        : null,
                    onPressed: () {
                      if (compareMap.length == 2) openBottomDrawer();
                    },
                    child:
                        Text('Compare ' + compareMap.length.toString() + "/2"),
                  ),
                )
              : SizedBox(),
          (isBottomDrawerOpen)
              ? CompareScreen(
                  comparedItems: compareMap,
                  onClose: () {
                    closeBottomDrawer();
                    var keys = compareMap.keys.toList();
                    for (var i = 0; i < keys.length; i++) {
                      if (!compareMap[keys[i]]['isCompared']) {
                        print('remove');

                        setState(() {
                          compareMap.remove(keys[i]);
                        });
                      }
                    }
                    // compareMap = compareMap;
                  })
              : SizedBox(),
        ],
      ),
    ));
  }

  Widget _rightDrawer() {
    return AnimatedContainer(
      transform: Matrix4.translationValues(r_xOffset, r_yOffset, 0),
      duration: Duration(milliseconds: 250),
      child: Container(
        width: r_xOffset * 4,
        color: Colors.white,
        padding: EdgeInsets.only(top: 50, left: 15.0, right: 15.0),
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
            Container(
              child: Column(
                children: <Widget>[
                  CustomDropdownWidget(
                    context: context,
                    items: countryList,
                    label: "Country",
                    hint: "Country",
                    onChanged: (value) {
                      // print(value);
                      setState(() {
                        if (value != null) {
                          print("nilai=" + value.toString());
                          var selected = countryRes.firstWhere(
                              (element) => element['name'] == value);
                          _valCountryId = selected['id'].toString();
                          // print(value);
                          // print(selected['id']);

                          _valState = '';

                          // print(_valState);
                          // getstate
                          getstate(selected['id'].toString());

                          widget._countryid = selected['id'].toString();
                        }
                      });
                    },
                    selectedItem: _valCountry,
                  ),
                  // CustomDropdownWidget(
                  //   context: context,
                  //   items: stateList,
                  //   label: "State",
                  //   hint: "State",
                  //   // popupItemDisabled: (String s) => s.startsWith('I'),
                  //   onChanged: (value) {
                  //     // print(value);
                  //     if (_valState != null) {
                  //       var selected = stateRes
                  //           .firstWhere((element) => element['name'] == value);

                  //       // print(value);
                  //       // print(selected['id'].toString());

                  //       widget._stateid = selected['id'].toString();
                  //     }
                  //   },
                  //   selectedItem: _valState,
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // close window
                      closeRightDrawer();

                      // search with filter
                      directoryList.clear();
                      // widget._category.utilities.clear();
                      widget._keyword = myController.text;
                      page = 1;
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
