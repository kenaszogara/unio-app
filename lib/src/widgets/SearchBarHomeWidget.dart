import '../../config/ui_icons.dart';
import 'package:flutter/material.dart';
import 'package:Unio/main.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/category.dart';
import '../models/utilities.dart';
import '../models/route_argument.dart';

class SearchBarHomeWidget extends StatelessWidget {
  // final TextEditingController _controller = TextEditingController();
  SearchBarHomeWidget({
    Key key,
  }) : super(key: key);
  List<String> suggestions = [
    /*"MIT",
    "Harvard University",
    "Stanford University",
    "Columbia University",*/
  ];
  final myController = TextEditingController();
  CategoriesList _categoriesList = new CategoriesList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
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
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).hintColor.withOpacity(0.4),
                    width: 1),
                borderRadius: BorderRadius.circular(10.0)),
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                TextField(
                  // controller:_controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'Search',
                    hintStyle: TextStyle(
                        color: Theme.of(context).focusColor.withOpacity(0.8)),
                    // prefixIcon: Icon(UiIcons.loupe,
                    //     size: 20, color: Theme.of(context).hintColor),
                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                    enabledBorder:
                        UnderlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder:
                        UnderlineInputBorder(borderSide: BorderSide.none),
                  ),
                  controller: myController,
                ),
                // Padding(
                //   padding: const EdgeInsets.only(right:30.0),
                //   child: IconButton(
                //     onPressed: () {
                //       // Scaffold.of(context).openEndDrawer();
                //     },
                //     icon: Icon(UiIcons.checked,
                //         size: 20,
                //         color: Theme.of(context).hintColor.withOpacity(0.5)),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: IconButton(
                    onPressed: () async {
                      // cari_keyword = myController.text;
                      // Scaffold.of(context).openEndDrawer();
                      cari_query =
                          "&name=" + myController.text.replaceAll(" ", "%20");
                      final response = await http.get(
                        Uri.parse(
                            // 'https://primavisiglobalindo.net/unio/public/api/university-majors'),
                            'https://primavisiglobalindo.net/unio/public/api/search/?keyword=universities' +
                                cari_query),
                        // Send authorization headers to the backend.
                        headers: {
                          HttpHeaders.authorizationHeader:
                              "VsNYL8JE4Cstf8gb9LYCobuxYWzIo71bvUkIVYXXVUO4RtvuRxGYxa3TFzsaOeHxxf4PRY7MIhBPJBly4H9bckY5Qr44msAxc0l4"
                        },
                      );

                      var hasilsearch = jsonDecode(response.body)['data'];
                      print(hasilsearch.toString());
                      // print(hasilsearch.length);
                      _categoriesList.list.elementAt(1).utilities.clear();
                      for (var i = 0; i < hasilsearch.length; i++) {
                        print(hasilsearch[i]['name']);

                        _categoriesList.list.elementAt(1).utilities.add(
                              new Utilitie(
                                  hasilsearch[i]['name'],
                                  hasilsearch[i]['logo_src'],
                                  '-',
                                  '-',
                                  '-',
                                  25,
                                  130,
                                  4.3,
                                  12.1),
                            );
                      }
                      // print(CategoriesList().list.elementAt(1).name);
                      Navigator.of(context).pushNamed('/Categorie',
                          arguments: RouteArgument(id: 101, argumentsList: [
                            _categoriesList.list.elementAt(1)
                          ]));
                    },
                    icon: Icon(UiIcons.loupe,
                        size: 20,
                        color: Theme.of(context).hintColor.withOpacity(0.5)),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    cari_keyword = myController.text;
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: Icon(UiIcons.settings_2,
                      size: 20,
                      color: Theme.of(context).hintColor.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlatButton(
                onPressed: () {
                  // Navigator.of(context).pushNamed('/Categories',
                  //     arguments: RouteArgument(id: 2, argumentsList: [
                  //       new CategoriesList().list.elementAt(0)
                  //     ]));
                },
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                color: Theme.of(context).backgroundColor,
                shape: StadiumBorder(),
                child: Text(
                  'Match with me',
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: _buildSuggestions(suggestions, context),
          )
        ],
      ),
    );
  }
}

_buildSuggestions(List<String> list, BuildContext context) {
  List<Widget> choices = List();
  list.forEach((item) {
    choices.add(
      Container(
        margin: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Theme.of(context).hintColor.withOpacity(0.2),
          ),
          padding:
              const EdgeInsets.only(left: 10.0, right: 10, top: 3, bottom: 3),
          child: Text(
            item,
            style: Theme.of(context).textTheme.body1.merge(
                  TextStyle(color: Theme.of(context).primaryColor),
                ),
          ),
        ),
      ),
    );
  });
  return choices;
}
