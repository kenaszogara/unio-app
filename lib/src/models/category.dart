import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/ui_icons.dart';
import 'package:flutter/material.dart';
import '../models/utilities.dart';
import '../models/favorites.dart';
import '../models/university.dart';

class Category {
  String id = UniqueKey().toString();
  String name;
  bool selected;
  IconData icon;
  Color color;
  List<University> universities = [];
  List<Utilitie> utilities;
  List<Favorite> favorites;

  Category(this.name, this.icon, this.selected, this.color, this.utilities);
}

class SubCategory {
  String id = UniqueKey().toString();
  String name;
  bool selected;
  List<Utilitie> utilities;

  SubCategory(this.name, this.selected, this.utilities);
}

class CategoriesList {
  List<Category> _list;

  List<Category> get list => _list;

  CategoriesList() {
    this._list = [
      new Category('University', FontAwesomeIcons.university, true, Colors.cyan, []),
      new Category('Field of study', FontAwesomeIcons.puzzlePiece, false, Colors.orange, []),
      new Category(
          'Vendor', FontAwesomeIcons.store, false, Colors.greenAccent, []),
      new Category(
          'Places to Live', FontAwesomeIcons.building, false, Colors.blueAccent, []),
      new Category(
          'Scholarship', FontAwesomeIcons.graduationCap, false, Colors.pinkAccent, []),
      new Category(
          'Article', FontAwesomeIcons.newspaper, false, Colors.deepPurpleAccent, []),
      // new Category('Ranking', FontAwesomeIcons.trophy, false, Colors.brown, []),
      new Category('Advice', FontAwesomeIcons.solidCompass, true, Colors.redAccent, []),
      new Category('Questionnaire', FontAwesomeIcons.userEdit, true, Colors.redAccent, []),
      // new Category('Bookmark', FontAwesomeIcons.solidHeart, true, Colors.redAccent, []),
      // new Category('Cart', FontAwesomeIcons.shoppingCart, true, Colors.redAccent, []),
    ];
  }

  selectById(String id) {
    this._list.forEach((Category category) {
      category.selected = false;
      if (category.id == id) {
        category.selected = true;
      }
    });
  }

  void clearSelection() {
    _list.forEach((category) {
      category.selected = false;
    });
  }
}

class FilterList {
  List<Category> _list;

  List<Category> get list => _list;

  FilterList() {
    this._list = [
      new Category('University', UiIcons.bar_chart, false, Colors.cyan, []),
      new Category('Field of study', UiIcons.laptop, false, Colors.orange, []),
      new Category(
          'Vendor', UiIcons.shopping_cart, false, Colors.greenAccent, []),
      new Category(
          'Places to Live', UiIcons.bedroom, false, Colors.blueAccent, []),
      new Category(
          'Scholarship', UiIcons.id_card, false, Colors.pinkAccent, []),
      new Category(
          'Article', UiIcons.books, false, Colors.deepPurpleAccent, []),
    ];
  }

  selectById(String id) {
    this._list.forEach((Category category) {
      category.selected = false;
      if (category.id == id) {
        category.selected = true;
      }
    });
  }

  void clearSelection() {
    _list.forEach((category) {
      category.selected = false;
    });
  }
}

class SubCategoriesList {
  List<SubCategory> _list;

  List<SubCategory> get list => _list;

  selectById(String id) {
    this._list.forEach((SubCategory subCategory) {
      subCategory.selected = false;
      if (subCategory.id == id) {
        subCategory.selected = true;
      }
    });
  }

  void clearSelection() {
    _list.forEach((category) {
      category.selected = false;
    });
  }
}
