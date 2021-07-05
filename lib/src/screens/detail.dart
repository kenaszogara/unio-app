import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';

// import 'package:Unio/config/app_config.dart';
import 'package:Unio/src/models/product_color.dart';
import 'package:Unio/src/models/route_argument.dart';
import 'package:Unio/src/widgets/CircularLoadingWidget.dart';
import 'package:Unio/src/widgets/ReviewsListWidget.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/ui_icons.dart';
import 'package:Unio/src/utilities/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/DrawerWidget.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class DetailWidget extends StatefulWidget {
  RouteArgument routeArgument;
  Color bookmarkColor = Color(0xFFFFFFFF);

  DetailWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _DetailWidgetState createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget>
    with SingleTickerProviderStateMixin {
  dynamic data;
  dynamic detailID;
  String detailType;

  Function onBookmark;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;
  int _tabIndex = 0;
  bool readMore = false;
  bool isBookmarked = false;

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

  @override
  void initState() {
    detailID = widget.routeArgument.param1[0];
    detailType = widget.routeArgument.param1[1];

    onBookmark = widget.routeArgument.param2;

    getData(detailID, detailType);

    _tabController =
        TabController(length: 2, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);

    print('lala');
    print(detailType);
    super.initState();
  }

  Future<void> addBookmark() async {
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
          'entity_id': detailID,
          'entity_type': detailType,
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
          isBookmarked = !isBookmarked;
        });

        // update bookmark in directory
        onBookmark();
      });

    if (response.statusCode != 200)
      return Future(() {
        // var data = json.decode(response.body);
        showOkAlertDialog(
          context: context,
          title: "There is an error",
        );
        setState(() {
          isBookmarked = !isBookmarked;
        });
      });

    return null;
  }

  void _launchURL(url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch url';
  }

  void _launchEmail(url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch url';
  }

  void _launchMap(q) async {
    String uri = q.replaceAll(" ", "%20");
    // print(uri);

    await canLaunch('http://maps.google.com/?q=' + uri)
        ? await launch('http://maps.google.com/?q=' + uri)
        : throw 'Could not launch http://maps.google.com/?q=' + uri;
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return data == null
        ? CircularLoadingWidget(
            height: double.infinity,
          )
        : SafeArea(
            child: Scaffold(
            key: _scaffoldKey,
            drawer: DrawerWidget(),
            bottomNavigationBar: BottomAppBar(
              elevation: 0,
              child: Container(
                height: 20,
              ),
            ),
            body: CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                floating: true,
                automaticallyImplyLeading: false,
                leading: new IconButton(
                  icon: new Icon(UiIcons.return_icon,
                      color: Theme.of(context).hintColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: <Widget>[
                  //new ShoppingCartButtonWidget(
                  //iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
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
                        /*child: CircleAvatar(
                          backgroundImage: AssetImage('img/user2.jpg'),
                        ),*/
                      )),
                ],
                backgroundColor: Theme.of(context).primaryColor,
                expandedHeight: 350,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Hero(
                    tag: 'lala tag',
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: headerImg(detailType),
                              ),
                            )),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                Theme.of(context).primaryColor,
                                Colors.white.withOpacity(0),
                                Colors.white.withOpacity(0),
                                Theme.of(context).scaffoldBackgroundColor
                              ],
                                  stops: [
                                0,
                                0.4,
                                0.6,
                                1
                              ])),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverStickyHeader(
                header: Container(
                  color: Color(0xffFAFAFA),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 22, left: 20, right: 20),
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                data['name'] != null
                                    ? data['name']
                                    : data['title'],
                                // overflow: TextOverflow.ellipsis,
                                // maxLines: 2,
                                style: Theme.of(context).textTheme.display2,
                              ),
                            ),
                            Wrap(
                              spacing: 10,
                              children: [
                                (detailType != 'articles')
                                    ? GestureDetector(
                                        onTap: () async {
                                          if (Global.instance.apiToken !=
                                              null) {
                                            addBookmark();

                                            setState(() {
                                              isBookmarked = !isBookmarked;
                                            });

                                            showOkAlertDialog(
                                                context: context,
                                                title: isBookmarked
                                                    ? 'Successfully Bookmarked'
                                                    : 'Successfully Unbookmarked');

                                            // update bookmark in directory
                                            onBookmark();
                                          } else {
                                            _showNeedLoginAlert(context);
                                          }
                                        },
                                        child: Chip(
                                          elevation: 2,
                                          shadowColor:
                                              Colors.grey.withOpacity(0.5),
                                          padding: EdgeInsets.all(0),
                                          label: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Icon(
                                                (isBookmarked)
                                                    ? FontAwesomeIcons
                                                        .solidHeart
                                                    : FontAwesomeIcons.heart,
                                                color: Color(0xFFDC3545),
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.white,
                                          shape: StadiumBorder(),
                                        ),
                                      )
                                    : SizedBox(),
                                (detailType != 'articles')
                                    ? GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            if (detailType == 'majors') {
                                              Navigator.of(context).pushNamed(
                                                  '/Detail',
                                                  arguments:
                                                      RouteArgument(param1: [
                                                    data['university']['id'],
                                                    'universities'
                                                  ], param2: () {}));
                                            } else {
                                              _launchURL(data['website']);
                                            }
                                          });
                                        },
                                        child: Chip(
                                          elevation: 2,
                                          shadowColor:
                                              Colors.grey.withOpacity(0.5),
                                          padding: EdgeInsets.all(0),
                                          label: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Transform(
                                                alignment: Alignment.center,
                                                transform:
                                                    Matrix4.rotationY(math.pi),
                                                child: Icon(
                                                  (detailType == 'majors')
                                                      ? Icons.reply
                                                      : Icons.language,
                                                  color: Theme.of(context)
                                                      .accentColor
                                                      .withOpacity(0.9),
                                                  size: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.white,
                                          shape: StadiumBorder(),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            )
                          ],
                        ),
                      ),
                      (data['is_sponsored'] != null)
                          ? Container(
                              // width: MediaQuery.of(context).size.width * 0.3,
                              // height: MediaQuery.of(context).size.height * 0.15,
                              margin: const EdgeInsets.only(
                                  left: 15.0, right: 15.0),
                              // padding: const EdgeInsets.all(15.0),

                              child: Column(
                                children: [
                                  Chip(
                                    padding: EdgeInsets.all(0),
                                    label: Wrap(
                                      spacing: 10,
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          FontAwesomeIcons.handshake,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        Text('UNIO Partner',
                                            style:
                                                TextStyle(color: Colors.white))
                                      ],
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.9),
                                    shape: StadiumBorder(),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 0, left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Column(
                                  children: [
                                    (detailType == 'majors')
                                        ? Text(
                                            (data['level'] != null)
                                                ? 'Level : ' + data['level']
                                                : '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2)
                                        : SizedBox(),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Column(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            (data['university'] != null)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        // height: MediaQuery.of(context).size.height * 0.15,
                                        margin: const EdgeInsets.all(15.0),
                                        padding: const EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          // border:
                                          //     Border.all(color: Colors.blueAccent)
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text(widget.utilitie.description.split("#")[0],maxLines: 5,),
                                            Text(
                                              data['university']['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.room,
                                                  size: 18.0,
                                                ),
                                                Text(
                                                  data['university']['country']
                                                      ['name'],
                                                  style: TextStyle(
                                                    // fontWeight: FontWeight.bold,
                                                    fontSize: 14.0,
                                                  ),
                                                )
                                              ],
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    '/Detail',
                                                    arguments:
                                                        RouteArgument(param1: [
                                                      data['university']['id'],
                                                      'universities'
                                                    ], param2: () {}));
                                              },
                                              child: Text('Visit'),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : SizedBox(),

                            // DESCRIPTION
                            (detailType != 'majors' &&
                                    detailType != 'articles' &&
                                    data['description'] != null)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        // height: MediaQuery.of(context).size.height * 0.15,
                                        margin: const EdgeInsets.all(15.0),
                                        padding: const EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          // border:
                                          //     Border.all(color: Colors.blueAccent)
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text(widget.utilitie.description.split("#")[0],maxLines: 5,),
                                            Text(
                                              'Description:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            (readMore)
                                                ? Text(
                                                    data['description']
                                                            .trim() ??
                                                        'There is no description',
                                                  )
                                                : Text(
                                                    data['description']
                                                            .trim() ??
                                                        'There is no description',
                                                    maxLines: 3,
                                                  ),
                                            (readMore)
                                                ? SizedBox()
                                                : Text(
                                                    '...',
                                                    textAlign: TextAlign.left,
                                                  ),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  readMore = !readMore;
                                                });
                                              },
                                              child: (readMore)
                                                  ? Text('Show Less')
                                                  : Text('Read More'),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : SizedBox(),

                            // DESCRIPTION
                            (detailType == 'articles' &&
                                    data['description'] != null)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        // height: MediaQuery.of(context).size.height * 0.15,
                                        margin: const EdgeInsets.all(15.0),
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text(widget.utilitie.description.split("#")[0],maxLines: 5,),

                                            Text(
                                              data['description'].trim() ??
                                                  'There is no description',
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : SizedBox(),

                            // INFORMATION
                            (detailType != 'majors' && detailType != 'articles')
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        // height: MediaQuery.of(context).size.height * 0.15,
                                        margin: const EdgeInsets.all(15.0),
                                        padding: const EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          // border:
                                          //     Border.all(color: Colors.blueAccent)
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Information:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            (data['country'] != null)
                                                ? ListTile(
                                                    leading: Icon(Icons.public),
                                                    title: Text('Country'),
                                                    subtitle: Text(
                                                      data['country']['name'],
                                                      // overflow:
                                                      //     TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                : SizedBox(),
                                            (data['website'] != null)
                                                ? ListTile(
                                                    onTap: () {
                                                      _launchURL(
                                                          data['website']);
                                                    },
                                                    leading: Icon(Icons
                                                        .language_outlined),
                                                    title: Text('Website'),
                                                    subtitle: Text(
                                                      data['website'],
                                                    ),
                                                  )
                                                : SizedBox(),
                                            (data['email'] != null)
                                                ? ListTile(
                                                    onTap: () {
                                                      _launchURL(data['email']);
                                                    },
                                                    leading: Icon(Icons.email),
                                                    title: Text('Email:'),
                                                    subtitle: Text(
                                                      data['email'],
                                                    ),
                                                  )
                                                : SizedBox(),
                                            (data['phone'] != null)
                                                ? ListTile(
                                                    leading: Icon(Icons.phone),
                                                    title: Text('Phone:'),
                                                    subtitle: Text(
                                                      data['phone'],
                                                    ),
                                                  )
                                                : SizedBox(),
                                            (data['address'] != null)
                                                ? ListTile(
                                                    onTap: () {
                                                      _launchMap(
                                                          data['address']);
                                                    },
                                                    leading: FaIcon(
                                                        FontAwesomeIcons
                                                            .mapMarked),
                                                    title: Text('Address:'),
                                                    subtitle: Text(
                                                      data['address'],
                                                    ),
                                                  )
                                                : SizedBox(),
                                            (data['year'] != null)
                                                ? ListTile(
                                                    leading: FaIcon(
                                                        FontAwesomeIcons
                                                            .graduationCap),
                                                    title: Text('Year:'),
                                                    subtitle: Text(
                                                      data['year'].toString(),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : SizedBox(),

                            (detailType == 'universities' &&
                                    data['rank'].isNotEmpty)
                                ? Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    // height: MediaQuery.of(context).size.height * 0.15,
                                    margin: const EdgeInsets.all(15.0),
                                    padding: const EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                      // border:
                                      //     Border.all(color: Colors.blueAccent)
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Rankings:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        ...rankingList(data['rank'])
                                      ],
                                    ),
                                  )
                                : SizedBox(),

                            // ADDRESS MAP
                            (detailType == 'universities')
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        // height: MediaQuery.of(context).size.height * 0.15,
                                        margin: const EdgeInsets.all(15.0),
                                        padding: const EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          // border:
                                          //     Border.all(color: Colors.blueAccent)
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Main Campus Location:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.room),
                                                Expanded(
                                                    child: Text(
                                                  detailType == 'universities'
                                                      ? data['address']
                                                      : data['university']
                                                          ['address'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              height: 180,
                                              width: double.maxFinite,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (detailType !=
                                                        'universities') {
                                                      _launchMap(
                                                          data['university']
                                                              ['name']);
                                                    } else {
                                                      _launchMap(data['name']);
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0),
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            'img/gps.png'),
                                                        fit: BoxFit.cover,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),

                            (detailType == 'universities' &&
                                    data['campus_locations'].isNotEmpty)
                                ? Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    // height: MediaQuery.of(context).size.height * 0.15,
                                    margin: const EdgeInsets.all(15.0),
                                    padding: const EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                      // border:
                                      //     Border.all(color: Colors.blueAccent)
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Campus Locations:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        ...campusesList(
                                            data['campus_locations'])
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        )
                        /*UtilitieHomeTabWidget(utilitie: widget._utilitie),*/
                      ],
                    ),
                  ]),
                ),
              )
            ]),
          ));
  }

  getData(int relationId, String type) async {
    String subUrl;
    switch (type) {
      case 'universities':
        subUrl = 'universities/';
        break;
      case 'majors':
        subUrl = 'university-majors/';
        break;
      case 'place-to-lives':
        subUrl = 'place-to-lives/';
        break;
      case 'services':
        subUrl = 'vendor-services/';
        break;
      case 'vendors':
        subUrl = 'vendors/';
        break;
      case 'scholarships':
        subUrl = 'university-scholarships/';
        break;
      case 'articles':
        subUrl = 'articles/';
        break;
      default:
        subUrl = 'universities/';
        break;
    }

    String url = SERVER_DOMAIN + subUrl + relationId.toString();

    Map<String, dynamic> request = Map();
    request['user_id'] = Global.instance.authId ?? '';
    /*request['user_id'] = Global.instance.authId;
    request['entity_type'] = '';
    request['name'] = '';*/

    String requestMap = '';
    int index = 0;
    request.forEach((key, value) {
      requestMap += '$key=$value';
      if (index != request.length - 1) requestMap += '&';
      index++;
    });
    url += '?$requestMap';

    Map<String, String> headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    var token = Global.instance.apiToken ??
        'RzEnFml7Pms7H7uL3djU8GeeGWC6FA3sdwMwsmBpZMtlgnxXlxEK3SNKxXqODS3o6XAo815HG8lmJdCZ8Wik9MHYFcD785KrgMQN';
    headers.addAll(
        <String, String>{HttpHeaders.authorizationHeader: 'Bearer $token'});
    print('============ noted: token ' + token);

    try {
      final client = new http.Client();
      final response = await client
          .get(
        Uri.parse(url),
        headers: headers,
        // body: json.encode(request),
      )
          .timeout(Duration(seconds: 60), onTimeout: () {
        throw 'Koneksi terputus. Silahkan coba lagi.';
      });
      print('========= noted: get requestMap ' +
          request.toString() +
          "===== url " +
          url);

      // var result = Map<String, dynamic>();
      if (response.statusCode == 200) {
        print('========= noted: get response body ' + response.body.toString());
        if (response.body.isNotEmpty) {
          dynamic jsonMap = json.decode(response.body)['data'];
          if (jsonMap != null) {
            setState(() {
              data = jsonMap;
              widget.bookmarkColor = data['is_checked'] != '0'
                  ? Color(0xFFDC3545)
                  : Color(0xFFFFFFFF);

              isBookmarked = data['is_checked'] != '0' ? true : false;
            });
          }

          String error = json.decode(response.body)['error'];
          if (error != null) {
            throw error;
          }
        }

        print('lala2');
        // print(data['university']['website']);
      } else {
        String error = json.decode(response.body)['error'];
        throw (error == '') ? 'Gagal memproses data' : error;
      }
    } on SocketException {
      throw 'Tidak ada koneksi internet. Silahkan coba lagi.';
    }
  }

  NetworkImage headerImg(type) {
    // print(type);
    // print(data);
    switch (type) {
      case 'universities':
        return new NetworkImage(data['header_src'] != null
            ? data['header_src']
            : "http://dev.unio.id/frontend/placeholder_university_header.jpg");
      // break;
      case 'majors':
        return new NetworkImage(data['university']['header_src'] != null
            ? data['university']['header_src']
            : "http://dev.unio.id/frontend/placeholder_university_header.jpg");
      // break;
      case 'vendors':
        return new NetworkImage(data['logo_src'] != null
            ? data['logo_src']
            : "http://dev.unio.id/frontend/placeholder_university_header.jpg");
      // break;
      case 'place-to-lives':
        return new NetworkImage(data['header_src'] != null
            ? data['header_src']
            : "http://dev.unio.id/frontend/placeholder_university_header.jpg");
      // break;
      case 'articles':
        return new NetworkImage(data['picture'] != null
            ? data['picture']
            : "http://dev.unio.id/frontend/placeholder_university_header.jpg");
      default:
        return new NetworkImage(
            'http://dev.unio.id/frontend/placeholder_university_header.jpg');
    }
  }

  List<Widget> rankingList(data) {
    List<Widget> _w = [];

    for (var i = 0; i < data.length; i++) {
      _w.add(ListTile(
        leading: FaIcon(
          FontAwesomeIcons.trophy,
          color: Color(0xFFF2C76E),
        ),
        title: Text('#' + data[i]['rank']),
        subtitle: Text(data[i]['name']),
      ));
    }

    return _w;
  }

  List<Widget> campusesList(data) {
    List<Widget> _w = [];

    for (var i = 0; i < data.length; i++) {
      _w.add(ListTile(
        // onTap: () {
        //   _launchURL(data[i]['map_link']);
        // },
        leading: FaIcon(
          FontAwesomeIcons.university,
          color: Color(0xFF5D9EDE),
        ),
        title: Text(data[i]['address']),
      ));
    }

    return _w;
  }
}

class SelectColorWidget extends StatefulWidget {
  SelectColorWidget({
    Key key,
  }) : super(key: key);

  @override
  _SelectColorWidgetState createState() => _SelectColorWidgetState();
}

class _SelectColorWidgetState extends State<SelectColorWidget> {
  ProductColorsList _productColorsList = new ProductColorsList();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_productColorsList.list.length, (index) {
        var _color = _productColorsList.list.elementAt(index);
        return buildColor(_color);
      }),
    );
  }

  SizedBox buildColor(ProductColor color) {
    return SizedBox(
      width: 38,
      height: 38,
      child: FilterChip(
        label: Text(''),
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        backgroundColor: color.color,
        selectedColor: color.color,
        selected: color.selected,
        shape: StadiumBorder(),
        avatar: Text(''),
        onSelected: (bool value) {
          setState(() {
            color.selected = value;
          });
        },
      ),
    );
  }
}
