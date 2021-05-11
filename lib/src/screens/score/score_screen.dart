import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Unio/constants.dart';
import 'package:Unio/src/controllers/question_controller.dart';
import 'package:flutter_svg/svg.dart';

class ScoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    QuestionController _qnController = Get.put(QuestionController());
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset("assets/icons/bg.svg", fit: BoxFit.fill),
          Column(
            children: [
              Spacer(flex: 3),
              Text(
                "Your Holland Code is",
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(color: kSecondaryColor),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "RCIA",
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(color: kSecondaryColor),
              ),
              SizedBox(
                height: 20,
              ),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 70),
                onPressed: () {
                  Navigator.of(context).pushNamed('/Tabs', arguments: 2);
                },
                child: Text(
                  'Advice',
                  style: Theme.of(context).textTheme.title.merge(
                        TextStyle(color: Theme.of(context).primaryColor),
                      ),
                ),
                color: Theme.of(context).accentColor,
                shape: StadiumBorder(),
              ),
              Spacer(flex: 3),
            ],
          )
        ],
      ),
    );
  }
}
