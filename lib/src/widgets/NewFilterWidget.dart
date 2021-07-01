import 'package:Unio/config/ui_icons.dart';
import 'package:Unio/src/models/category.dart';
import 'package:Unio/src/widgets/CustomDropdownSearchWidget.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../models/product_color.dart';
import '../models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Unio/main.dart';

class NewFilterWidget extends StatefulWidget {
  @override
  _NewFilterWidgetState createState() => _NewFilterWidgetState();
}

class _NewFilterWidgetState extends State<NewFilterWidget> {
  final myController = TextEditingController();
  int categoryId = 1;
  String _categoryGroup = "";
  String _valCountry;
  String _valState;
  String _valCountryid;
  String _valStateid;
  String _valUniid;
  String _valDistrict;
  String _valCategory;
  String _valUniversity;

  // final List<DropdownMenuItem> countryitem = [];
  // final List<DropdownMenuItem> categoriitem = [];
  // final List<DropdownMenuItem> universityitem = [];
  // final List<DropdownMenuItem> stateitem = [];
  // final List<DropdownMenuItem> districtitem = [];

  final List<String> countryitem = [];
  final List<String> categoriitem = [];
  final List<String> universityitem = [];
  final List<String> stateitem = [];
  final List<String> districtitem = [];

  var propinsi = List();
  var state = List();
  var district = List();
  var category = List();
  var universities = List();

  CategoriesList _categoriesList = new CategoriesList();
  FilterList _filterList = new FilterList();
  ProductColorsList _productColorsList = new ProductColorsList();

  @override
  void initState() {
    ambildata();
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
    print(response.body);
    setState(() {
      state = jsonDecode(response.body)['data']['data'];
    });
    print(state.toString());
    // state = [{"id":1,"name":"Jawa Barat"},{"id":2,"name":"Jawa Tengah"},{"id":3,"name":"Jawa Timur"},{"id":4,"name":"DKI Jakarta"}];
    for (var i = 0; i < state.length; i++) {
      setState(() {
        // stateitem.add(DropdownMenuItem(
        //   child: Text(state[i]['name']),
        //   value: state[i]['name'],
        // ));

        stateitem.add(state[i]['name'].toString());
      });
    }
  }

  void getcountry() async {
    final response = await http.get(
      Uri.parse('https://primavisiglobalindo.net/unio/public/api/countries'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            "VsNYL8JE4Cstf8gb9LYCobuxYWzIo71bvUkIVYXXVUO4RtvuRxGYxa3TFzsaOeHxxf4PRY7MIhBPJBly4H9bckY5Qr44msAxc0l4"
      },
    );
    print(response.body);
    setState(() {
      propinsi = jsonDecode(response.body)['data'];
    });
    print(propinsi.toString());
    // state = [{"id":1,"name":"Jawa Barat"},{"id":2,"name":"Jawa Tengah"},{"id":3,"name":"Jawa Timur"},{"id":4,"name":"DKI Jakarta"}];
    countryitem.clear();
    for (var i = 0; i < propinsi.length; i++) {
      setState(() {
        // countryitem.add(DropdownMenuItem(
        //   child: Text(propinsi[i]['name']),
        //   value: propinsi[i]['name'],
        // ));

        countryitem.add(propinsi[i]['name'].toString());
      });
    }
  }

  void ambildata() async {
    myController.text = cari_keyword;
    getcountry();
    // final response = await http.get(
    //   Uri.parse('https://primavisiglobalindo.net/unio/public/api/countries'),
    //   // Send authorization headers to the backend.
    //   headers: {
    //     HttpHeaders.authorizationHeader:
    //     "VsNYL8JE4Cstf8gb9LYCobuxYWzIo71bvUkIVYXXVUO4RtvuRxGYxa3TFzsaOeHxxf4PRY7MIhBPJBly4H9bckY5Qr44msAxc0l4"
    //   },
    // );
    // print(response.body);
    // setState(() {
    //   propinsi = jsonDecode(response.body)['data'];
    // });
    // // propinsi = [{"id":1,"name":"Indonesia"},{"id":2,"name":"United States"},{"id":3,"name":"Belanda"},{"id":4,"name":"Malaysia"}];
    // for (var i = 0; i < propinsi.length; i++) {
    //   setState(() {
    //     countryitem.add(DropdownMenuItem(
    //       child: Text(propinsi[i]['name']),
    //       value: propinsi[i]['name'],
    //     ));
    //   });
    // }

    print(propinsi.toString());
    getCategory();
    // getuniversity();
    // getstate("1");
    // getdistrict("1");
  }

  void getdistrict(String stateid) async {
    final response = await http.get(
      Uri.parse('https://primavisiglobalindo.net/unio/public/api/districts'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            "VsNYL8JE4Cstf8gb9LYCobuxYWzIo71bvUkIVYXXVUO4RtvuRxGYxa3TFzsaOeHxxf4PRY7MIhBPJBly4H9bckY5Qr44msAxc0l4"
      },
    );
    print(response.body);
    setState(() {
      district = jsonDecode(response.body)['data'];
    });
    print(district.toString());
    // district = [{"id":1,"name":"Surabaya"},{"id":2,"name":"Jakarta"},{"id":3,"name":"Malang"},{"id":4,"name":"Medan"},];
    for (var i = 0; i < district.length; i++) {
      setState(() {
        // districtitem.add(DropdownMenuItem(
        //   child: Text(district[i]['name']),
        //   value: district[i]['name'],
        // ));

        districtitem.add(district[i]['name'].toString());
      });
    }
  }

  void getuniversity(String countryid, String stateid) async {
    print(countryid);
    print(stateid);

    if (stateid == null) stateid = "";
    print(
        'https://primavisiglobalindo.net/unio/public/api/search/?keyword=universities&country=' +
            countryid +
            '&state=' +
            stateid);
    final response = await http.get(
      Uri.parse(
          'https://primavisiglobalindo.net/unio/public/api/search/?keyword=universities&country=' +
              countryid +
              '&state=' +
              stateid),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            "VsNYL8JE4Cstf8gb9LYCobuxYWzIo71bvUkIVYXXVUO4RtvuRxGYxa3TFzsaOeHxxf4PRY7MIhBPJBly4H9bckY5Qr44msAxc0l4"
      },
    );
    print(response.body);
    setState(() {
      universities = jsonDecode(response.body)['data'];
    });
    print(universities.toString());
    // district = [{"id":1,"name":"Surabaya"},{"id":2,"name":"Jakarta"},{"id":3,"name":"Malang"},{"id":4,"name":"Medan"},];
    universityitem.clear();
    for (var i = 0; i < universities.length; i++) {
      setState(() {
        // universityitem.add(DropdownMenuItem(
        //   child: Text(universities[i]['name']),
        //   value: universities[i]['name'],
        // ));

        universityitem.add(universities[i]['name'].toString());
      });
    }
  }

  void getCategory() async {
    final response = await http.get(
      Uri.parse(
          'https://primavisiglobalindo.net/unio/public/api/vendor-categories'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader:
            "VsNYL8JE4Cstf8gb9LYCobuxYWzIo71bvUkIVYXXVUO4RtvuRxGYxa3TFzsaOeHxxf4PRY7MIhBPJBly4H9bckY5Qr44msAxc0l4"
      },
    );
    print(response.body);
    setState(() {
      category = jsonDecode(response.body)['data']['data'];
    });
    print(category.toString());
    // district = [{"id":1,"name":"Surabaya"},{"id":2,"name":"Jakarta"},{"id":3,"name":"Malang"},{"id":4,"name":"Medan"},];

    for (var i = 0; i < category.length; i++) {
      setState(() {
        // categoriitem.add(DropdownMenuItem(
        //   child: Text(category[i]['name']),
        //   value: category[i]['name'],
        // ));

        categoriitem.add(category[i]['name'].toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Refine Results'),
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        categoryId = 1;
                        clearSelection();
                      });
                    },
                    /*child: Text(
                      'Clear',
                      style: Theme.of(context).textTheme.body2,
                    ),*/
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                primary: true,
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.4),
                              width: 1),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: <Widget>[
                          TextField(
                            controller: myController,
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
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      'Categories',
                    ),
                    children: List.generate(_filterList.list.length, (index) {
                      var _category = _filterList.list.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: new Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _category.icon,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 10, height: 10),
                                Text(
                                  _category.name,
                                  style: new TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                            new Radio(
                              value: _category.name,
                              groupValue: _categoryGroup,
                              onChanged: (value) {
                                setState(() {
                                  // _valCountry = null;
                                  // countryitem.clear();
                                  // getcountry();
                                  /*if (_category.name == "Field of study") {
                                    getuniversity(_valCountryid, _valStateid);
                                  }*/
                                  _categoryGroup = value;
                                  categoryId = index;
                                  //
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            (_categoryGroup == "University" ||
                    _categoryGroup == "Field of study")
                ? Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        // Text("Country :"),
                      ],
                    ),
                  )
                : Container(),
            (_categoryGroup == "University" ||
                    _categoryGroup == "Field of study")
                ? Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                    child: CustomDropdownWidget(
                      context: context,
                      items: countryitem,
                      label: "Country",
                      hint: "Country",
                      // popupItemDisabled: (String s) => s.startsWith('I'),
                      onChanged: (value) {
                        setState(() {
                          _valCountry = value;
                          if (_valCountry != null) {
                            print("nilai=" + value.toString());
                            var estateSelected = propinsi.firstWhere(
                                (element) => element['name'] == value);
                            _valCountryid = estateSelected['id'].toString();
                            // someStuffs.firstWhereOrNull((element) => element.id == 'Cat');
                            // print(estateSelected);
                            print(value);
                            // print(estateSelected['id']);

                            getstate(estateSelected['id'].toString());
                            if (_categoryGroup == "Field of study") {
                              getuniversity(
                                  estateSelected['id'].toString(), "");
                            }
                          }
                        });
                      },
                      selectedItem: _valCountry,
                    ),
                  )
                : Container(),
            (_categoryGroup == "University" ||
                    _categoryGroup == "Field of study" ||
                    _categoryGroup == "Vendor")
                ? Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        // Text("State :"),
                      ],
                    ),
                  )
                : Container(),
            // (_categoryGroup == "University" ||
            //         _categoryGroup == "Field of study" ||
            //         _categoryGroup == "Vendor")
            //     ? Padding(
            //         padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            //         child: CustomDropdownWidget(
            //           context: context,
            //           items: stateitem,
            //           label: "State",
            //           hint: "State",
            //           // popupItemDisabled: (String s) => s.startsWith('I'),
            //           onChanged: (value) {
            //             setState(() {
            //               _valState = value;
            //               var estateSelected2 = propinsi.firstWhere(
            //                   (element) => element['name'] == _valCountry);
            //               _valStateid = "";
            //               _valCountryid = estateSelected2['id'].toString();
            //               if (_valState != null) {
            //                 var estateSelected = state.firstWhere(
            //                     (element) => element['name'] == value);
            //                 _valStateid = estateSelected['id'].toString();

            //                 // someStuffs.firstWhereOrNull((element) => element.id == 'Cat');
            //                 // print(estateSelected);
            //                 print(value);
            //                 // print(estateSelected['id']);

            //               }
            //               print(value);
            //               // if (_categoryGroup == "Field of study") {
            //               getuniversity(_valCountryid, _valStateid);
            //               // }
            //               // getuniversity(countryid, stateid)
            //             });
            //           },
            //           selectedItem: _valState,
            //         ),
            //       )
            //     : Container(),
            (_categoryGroup == "#Field of study")
                ? Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        // Text("University :"),
                      ],
                    ),
                  )
                : Container(),
            (_categoryGroup == "#Field of study")
                ? CustomDropdownWidget(
                    context: context,
                    items: universityitem,
                    label: "University",
                    hint: "University",
                    // popupItemDisabled: (String s) => s.startsWith('I'),
                    onChanged: (value) {
                      setState(() {
                        _valUniversity = value;
                        if (_valUniversity != null) {
                          var estateSelected = universities.firstWhere(
                              (element) => element['name'] == value);
                          _valUniid = estateSelected['id'].toString();
                        }
                        print(value);
                        print(_valUniid);
                      });
                    },
                    selectedItem: _valUniversity,
                  )
                : Container(),
            SizedBox(height: 20.0,),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/Directory',
                    arguments: new RouteArgument(argumentsList: [
                      /*Category('University', UiIcons.bar_chart, true,
                           Colors.cyan, [])*/
                      _filterList.list[categoryId] ??
                          Category('Field of study', UiIcons.bar_chart, true,
                              Colors.cyan, []),
                      myController.text,
                      _valCountryid.toString() ?? '',
                      _valStateid.toString() ?? '',
                      _valCountry,
                      _valState
                    ]));
              },
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              color: Theme.of(context).accentColor,
              shape: StadiumBorder(),
              child: Text(
                'Apply Filters',
                textAlign: TextAlign.start,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 15)
          ],
        ),
      ),
    );
  }

  void clearSelection() {
    this._categoriesList.clearSelection();
  }
}
