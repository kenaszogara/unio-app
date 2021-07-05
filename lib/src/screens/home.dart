import 'dart:convert';

import 'package:Unio/src/models/university.dart';
import 'package:Unio/src/utilities/global.dart';

import '../../config/ui_icons.dart';
import '../models/category.dart';
import '../widgets/CategoriesIconsContainerWidget.dart';
import '../widgets/HomeSliderWidget.dart';
import 'package:flutter/material.dart';
import '../widgets/PopularLocationCarouselWidget.dart';
import '../widgets/SearchBarHomeWidget.dart';
import 'package:http/http.dart' as http;

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with SingleTickerProviderStateMixin {
  CategoriesList _categoriesList = new CategoriesList();

  List<University> _universityList;

  Animation animationOpacity;
  AnimationController animationController;

  @override
  void initState() {
    _universityList = [];

    fetchData();

    animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    CurvedAnimation curve =
        CurvedAnimation(parent: animationController, curve: Curves.easeIn);
    animationOpacity = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {});
      });

    animationController.forward();

    super.initState();
  }

  void fetchData() async {
    // var type = "majors";
    String url = SERVER_DOMAIN + "frontend-home";

    print('========= noted: query all item ' + url);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('========= noted: get response body ' + response.body.toString());
      if (response.body.isNotEmpty) {
        List universities =
            await json.decode(response.body)['data']['university'];
        if (universities != null && universities.isNotEmpty) {
          for (var i = 0; i < universities.length; i++) {
            print('university $i');
            setState(() {
              _universityList.add(new University(
                  universities[i]['id'],
                  universities[i]['name'],
                  universities[i]['description'],
                  universities[i]['website'],
                  universities[i]['logo_src'],
                  universities[i]['header_src'] != null
                      ? universities[i]['header_src']
                      : "http://dev.unio.id/frontend/placeholder_university_header.jpg"));
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            HomeSliderWidget(),
            Container(
              margin: const EdgeInsets.only(top: 150, bottom: 20),
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: SearchBarHomeWidget(),
            ),
          ],
        ),
        Container(
            padding: const EdgeInsets.only(right: 2, left: 2),
            child: CategoriesIconsContainerWidget(
              // categoriesList: _categoriesList,
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: <Widget>[
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    UiIcons.favorites,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    'Popular',
                    style: Theme.of(context).textTheme.display1,
                  ),
                ),
              ],
            )),
        (_universityList.isNotEmpty)
            ? PopularLocationCarouselWidget(
                heroTag: 'home_flash_sales', universityList: _universityList)
            : CircularProgressIndicator(),
      ],
    ));
  }
}
