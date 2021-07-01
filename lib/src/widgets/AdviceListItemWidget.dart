import 'package:Unio/src/models/advice.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/ui_icons.dart';
import '../models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:Unio/src/utilities/global.dart';

// ignore: must_be_immutable
class AdviceListItemWidget extends StatefulWidget {
  String heroTag;
  Advice advice;
  VoidCallback onBookmarked;
  Color dismissibleColor;
  Widget dismissibleIcon;

  AdviceListItemWidget(
      {Key key,
      this.heroTag,
      this.advice,
      this.onBookmarked,
      this.dismissibleColor,
      this.dismissibleIcon})
      : super(key: key);

  @override
  _AdviceListItemWidgetState createState() => _AdviceListItemWidgetState();
}

class _AdviceListItemWidgetState extends State<AdviceListItemWidget> {
  @override
  Widget build(BuildContext context) {
    return
        // ListTile(
        // key: Key(this.widget.advice.hashCode.toString()),
        // background: Container(
        //   color: widget.dismissibleColor == null
        //       ? Colors.red
        //       : widget.dismissibleColor,
        //   child: Align(
        //     alignment: Alignment.centerRight,
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 20),
        //       child: (widget.dismissibleIcon == null)
        //           ? Icon(
        //               UiIcons.trash,
        //               color: Colors.white,
        //             )
        //           : widget.dismissibleIcon,
        //     ),
        //   ),
        // ),
        // onBookmarked: (direction) {
        //   // Remove the item from the data source.
        //   setState(() {
        //     widget.onBookmarked();
        //   });

        // Then show a snackbar.
        // Scaffold.of(context).showSnackBar(SnackBar(
        //     content: Text(
        //         "The ${widget.advice.majorName} favorite is removed from wish list")));
        // },
        // child:
        InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        print(widget.advice.majorId);
        Navigator.of(context).pushNamed('/Detail',
            arguments: RouteArgument(
                param1: [widget.advice.majorId, 'majors'],
                param2: () {
                  setState(() {
                    widget.advice.isChecked = !widget.advice.isChecked;
                  });
                }));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: widget.heroTag + widget.advice.id,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(
                      image: NetworkImage(widget.advice.universityLogo),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.advice.majorName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subhead,
                        ),
                        Row(
                          children: <Widget>[
                            FaIcon(
                              FontAwesomeIcons.graduationCap,
                              size: 12.0,
                              color: Color(0xFF5D9EDE),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Text(
                                widget.advice.level.toString(),
                                style: Theme.of(context).textTheme.body1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        Row(
                          children: <Widget>[
                            FaIcon(
                              FontAwesomeIcons.university,
                              size: 12.0,
                              color: Color(0xFF5D9EDE),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Text(
                                widget.advice.universityName.toString(),
                                style: Theme.of(context).textTheme.body1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          widget.onBookmarked();
                        },
                        child: (widget.advice.isChecked)
                            ? Icon(FontAwesomeIcons.solidHeart,
                                color: Color(0xFFDC3545))
                            : Icon(FontAwesomeIcons.heart,
                                color: Color(0xFFDC3545)),
                      )
                    ],
                  )
                  // Text('FOS', style: Theme.of(context).textTheme.body2),
                ],
              ),
            )
          ],
        ),
      ),
      // ),
    );
  }
}
