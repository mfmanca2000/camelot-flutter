import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rousseau_vote/src/screens/blog_screen.dart';
import 'package:rousseau_vote/src/screens/elected_screen.dart';
import 'package:rousseau_vote/src/screens/main/main_page.dart';
import 'package:rousseau_vote/src/screens/polls_screen.dart';
import 'package:rousseau_vote/src/screens/user_profile_screen.dart';

const List<MainPage> MAIN_PAGES = <MainPage>[
  MainPage(
      titleKey: 'blog',
      iconData: MdiIcons.newspaperVariantOutline,
      selectedIconData: MdiIcons.newspaperVariant,
      type: MainPageType.BLOG,
      page: BlogScreen()),
  MainPage(
      titleKey: 'vote',
      iconData: MdiIcons.voteOutline,
      selectedIconData: MdiIcons.vote,
      type: MainPageType.POLLS,
      page: PollsScreen()),
  MainPage(
      titleKey: 'elected',
      iconData: MdiIcons.accountGroupOutline,
      selectedIconData: MdiIcons.accountGroup,
      type: MainPageType.ELECTED,
      page: ElectedScreen()),
  MainPage(
      titleKey: 'profile',
      iconData: MdiIcons.accountOutline,
      selectedIconData: MdiIcons.account,
      type: MainPageType.PROFILE,
      page: UserProfileScreen(UserProfileArguments()),
      hasToolbar: false),
];
