import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rousseau_vote/src/injection/injector_config.dart';
import 'package:rousseau_vote/src/l10n/rousseau_localizations.dart';
import 'package:rousseau_vote/src/models/arguments/blog_instant_article_arguments.dart';
import 'package:rousseau_vote/src/models/browser_arguments.dart';
import 'package:rousseau_vote/src/models/poll.dart';
import 'package:rousseau_vote/src/models/poll_detail_arguments.dart';
import 'package:rousseau_vote/src/screens/blog_instant_article_screen.dart';
import 'package:rousseau_vote/src/screens/in_app_browser.dart';
import 'package:rousseau_vote/src/screens/poll_details_screen.dart';
import 'package:rousseau_vote/src/screens/polls_screen.dart';
import 'package:rousseau_vote/src/screens/success_screen.dart';
import 'package:rousseau_vote/src/screens/user_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rousseau_vote/src/widgets/error_dialog.dart';
import 'package:rousseau_vote/src/widgets/done_dialog.dart';

void showSimpleSnackbar(BuildContext context, String textKey, {bool dismissable = false}) {

  final SnackBarAction action = dismissable ? SnackBarAction(
        label: RousseauLocalizations.getText(context, 'close'),
        onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
  ) : null;

  Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(RousseauLocalizations.getText(context, textKey)),
        action: action,
      )
  );
}

void showRousseauSnackbar(BuildContext context,
    GlobalKey<ScaffoldState> scaffoldState, String errorMessage) {
  final SnackBar snackBar = SnackBar(
    content: Text(RousseauLocalizations.getText(context, errorMessage)),
    duration: const Duration(seconds: 5),
  );

  scaffoldState.currentState.showSnackBar(snackBar);
}

String formatDate(BuildContext context, DateTime dateTime) {
  return DateFormat.yMMMd(RousseauLocalizations.of(context).currentLanguage)
      .addPattern(" '-' ")
      .add_jm()
      .format(dateTime);
}

Future<void> openUrlExternal(BuildContext context, String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Function openUrlExternalAction(BuildContext context, String url) {
  return () {
    openUrlExternal(context, url);
  };
}

Future<void> openUrlInternal(BuildContext context, String url) async {
  url = await resolveUrl(url);
  if (isBlogArticle(url)) {
    final String slug = getArticleSlug(url);
    openBlogInstantArticle(context, url, slug);
  } else {
    openLink(context, BrowserArguments(url: url));
  }
}

Function openUrlInternalAction(BuildContext context, String url) {
  return () {
    openUrlInternal(context, url);
  };
}

Function openBlogInstantArticleAction(BuildContext context, String url, String slug) {
  return () {
    openBlogInstantArticle(context, url, slug);
  };
}

void openBlogInstantArticle(BuildContext context, String url, String slug) {
  final BlogInstantArticleArguments arguments = getBlogInstantArticleArguments(url, slug);
  Navigator.of(context)
      .pushNamed(BlogInstantArticleScreen.ROUTE_NAME, arguments: arguments);
}

void goBack(BuildContext context) {
  Navigator.of(context).pop();
}

void openLink(BuildContext context, BrowserArguments arguments) {
  Navigator.of(context)
      .pushNamed(InAppBrowser.ROUTE_NAME, arguments: arguments);
}

Function openLinkAction(BuildContext context, BrowserArguments arguments) {
  return () {
    openLink(context, arguments);
  };
}

void openProfile(BuildContext context, String slug) {
  openRoute(context, UserProfileScreen.ROUTE_NAME, arguments: UserProfileArguments(slug));
}

Function openProfileAction(BuildContext context, String slug) {
  return () {
    openProfile(context, slug);
  };
}

Function openPollDetailsAction(BuildContext context, Poll poll) {
  return () {
    openRoute(
      context,
      PollDetailsScreen.ROUTE_NAME,
      arguments: PollDetailArguments(poll.slug, false),
    );
  };
}

void openRoute(BuildContext context, String route, {Object arguments, bool replace = false}) {
  if (replace) {
    Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
  } else {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }
}

void openModalSuccessPage(BuildContext context,{String message}){
  Navigator.of(context).pushAndRemoveUntil<dynamic>(MaterialPageRoute<dynamic>(builder: (context) => SuccessScreen(message: message), fullscreenDialog: true),ModalRoute.withName(PollsScreen.ROUTE_NAME));
}

Function openRouteAction(BuildContext context, String route, {Object arguments, bool replace = false}) {
  return () {
    openRoute(context, route, arguments: arguments, replace: replace);
  };
}

BlogInstantArticleArguments getBlogInstantArticleArguments(String url, String slug) {
  return BlogInstantArticleArguments(url, slug);
}

String getArticleSlug(String url) {
  if (!isBlogArticle(url)) {
    return null;
  }
  return url.substring(url.lastIndexOf('/') + 1, url.lastIndexOf('.'));
}

bool isBlogArticle(String url) {
  return url.startsWith('https://www.ilblogdellestelle.it/');
}



/// If it's a shorted url it resolve the actual url (e.g.: bit.ly)
Future<String> resolveUrl(String url) async {
  if (!url.startsWith('http://bit.ly/') && !url.startsWith('https://bit.ly/')) {
    return url;
  }
  try {
    final Dio dio = getIt<Dio>();
    final Response<String> response = await dio.get(
      url,
      options: Options(followRedirects: false,)
    );
  } on DioError catch (dioError) {
    final Response<dynamic> response = dioError.response;
    if (response != null && response.isRedirect && response.headers['Location'] != null) {
      return response.headers['Location'][0];
    }
  } catch (_) {}
  return url;
}

void showError(BuildContext context, Function endAction, String errorMessage) {
  Navigator.of(context).pop();
  showDialog<AlertDialog>(
    context: context,
    builder: (BuildContext context) {
      return ErrorDialog(
        RousseauLocalizations.getText(context, errorMessage),
        endAction
      );
    }
  );
}

void showDone(BuildContext context,Function endAction) {
  Navigator.of(context).pop();
  showDialog<AlertDialog>(
    context: context,
    builder: (BuildContext context) {
      return DoneDialog(endAction);
    }
  );
}
