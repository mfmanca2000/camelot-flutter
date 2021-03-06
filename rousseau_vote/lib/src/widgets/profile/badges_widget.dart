
import 'package:flutter/cupertino.dart';
import 'package:rousseau_vote/src/models/profile/badge.dart';
import 'package:rousseau_vote/src/util/profile_util.dart';

class BadgesWidget extends StatelessWidget {

  BadgesWidget(List<Badge> badges, this.iconSize, { this.padding = 6, this.showInactive = false }) : _badgeImagesPaths = getBadgesImages(badges, showInactive: showInactive);

  final List<String> _badgeImagesPaths;
  final double iconSize;
  final double padding;
  final bool showInactive;

  @override
  Widget build(BuildContext context) {
    final List<Widget> badgeImagesWidgets = <Widget>[];
    for (String badgeImagePath in _badgeImagesPaths) {
      badgeImagesWidgets.add(Container(
          padding: EdgeInsets.only(left: padding),
          child: Image.asset(
            badgeImagePath,
            width: iconSize,
          )));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: badgeImagesWidgets,
    );
  }

}