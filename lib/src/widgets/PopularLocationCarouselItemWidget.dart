import 'package:Unio/src/models/university.dart';
import 'package:Unio/src/utilities/global.dart';

import '../models/utilities.dart';
import '../models/route_argument.dart';
//import '../widgets/AvailableProgressBarWidget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PopularLocationCarouselItemWidget extends StatefulWidget {
  String heroTag;
  double marginLeft;
  University university;

  PopularLocationCarouselItemWidget({
    Key key,
    this.heroTag,
    this.marginLeft,
    this.university,
  }) : super(key: key);

  @override
  _PopularLocationCarouselItemWidgetState createState() =>
      _PopularLocationCarouselItemWidgetState();
}

class _PopularLocationCarouselItemWidgetState
    extends State<PopularLocationCarouselItemWidget> {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(widget.university.universityId is int);
        // if (Global.instance.apiToken != null) {
          Navigator.of(context).pushNamed('/Detail',
              arguments: RouteArgument(
                  param1: [widget.university.universityId, 'universities'],
                  param2: () {}));
      //   } else {
      //     _showNeedLoginAlert(context);
      //   }
      },
      child: Container(
        margin: EdgeInsets.only(left: this.widget.marginLeft, right: 20),
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Hero(
              tag: widget.heroTag + widget.university.id,
              child: Container(
                width: 180,
                height: 185,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    // image: AssetImage(utilitie.image),
                    image: (this.widget.heroTag == "home_flash_sales")
                        ? NetworkImage(widget.university.logo)
                        : NetworkImage(
                            "https://i.ibb.co/RgwbsQy/icon-campus.jpg"),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 160),
              width: 140,
              height: 50,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).hintColor.withOpacity(0.15),
                        offset: Offset(0, 3),
                        blurRadius: 10)
                  ]),
              child: Center(
                child: Text(
                  widget.university.name,
                  style: Theme.of(context).textTheme.body2,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
                //SizedBox(height: 7),
                //Text(
                //'${utilitie.available} Available',
                //style: Theme.of(context).textTheme.body1,
                //overflow: TextOverflow.ellipsis,
                //),
              ),
            )
          ],
        ),
      ),
    );
  }
}
