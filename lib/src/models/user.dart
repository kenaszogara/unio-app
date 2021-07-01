import 'package:Unio/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:Unio/src/utilities/global.dart';

enum UserState { available, away, busy }

class User {
  String id = UniqueKey().toString();
  String name;
  String email;
  String gender;
  DateTime dateOfBirth;
  String birthPlace;
  String avatar;
  String address;
  String phone;
  String school;
  String graduate;
  String identity;
  String religion;

  UserState userState;

  User.init();

  User.basic(this.name, this.avatar, this.userState);

  User.advanced(
      this.name,
      this.email,
      this.gender,
      this.dateOfBirth,
      this.birthPlace,
      this.avatar,
      this.address,
      this.phone,
      this.school,
      this.graduate,
      this.identity,
      this.religion,
      this.userState);

  User getCurrentUser() {
    // if (Global.instance.apiToken == null) {
    //   return User.advanced('Guest User', '-', '-', DateTime(2000, 01, 01), '-',
    //       'img/user2.jpg', '-', '-', '-', '-', '-', '-', UserState.available);
    // } else {
    return User.advanced(
        Global.instance.authName ?? 'Guest User',
        Global.instance.authEmail ?? '-',
        Global.instance.authGender ?? 'Hidden',
        Global.instance.authBirthDate,
        Global.instance.authBirthPlace ?? '-',
        Global.instance.authPicture ?? '-',
        Global.instance.authAddress ?? '-',
        Global.instance.authPhone ?? '-',
        Global.instance.authSchool ?? '-',
        Global.instance.authGraduate ?? '-',
        Global.instance.authIdentity ?? '-',
        Global.instance.authReligion ?? '-',
        UserState.available);
    // }
  }

  void logoutUser() async {
    await storage.deleteAll();

    Global.instance.authId = null;
    Global.instance.authName = 'Guest User';
    Global.instance.apiToken = null;
    Global.instance.authEmail = null;
    Global.instance.authGender = null;
    Global.instance.authBirthDate = null;
    Global.instance.authBirthPlace = null;
    Global.instance.authPicture = null;
    Global.instance.authAddress = null;
    Global.instance.authPhone = null;
    Global.instance.authSchool = null;
    Global.instance.authGraduate = null;
    Global.instance.authIdentity = null;
    Global.instance.authReligion = null;

    print(storage.readAll());

    new User.init().getCurrentUser();
  }

  String getDateOfBirth() {
    return this.dateOfBirth != null
        ? DateFormat('dd-MM-yyyy').format(this.dateOfBirth)
        : '-';
  }

  String initials() {
    List<String> name = this.name.split(' ');

    return ((name[0] != null ? name[0][0] : "") +
            (name.length > 1 ? (name[1] != null ? name[1][0] : "") : ""))
        .toUpperCase();
  }

  bool hasPicture(url) {
    // final url_avatar = 'https://ui-avatars.com/api/';
    if (url == null) {
      return false;
    }
    
    final uri = Uri.parse(url);
    if (uri.host == 'ui-avatars.com') {
      return false;
    } else {
      return true;
    }
  }
}
