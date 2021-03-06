import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rousseau_vote/src/config/app_constants.dart';
import 'package:rousseau_vote/src/injection/injector_config.dart';
import 'package:rousseau_vote/src/l10n/rousseau_localizations.dart';
import 'package:rousseau_vote/src/models/poll.dart';
import 'package:rousseau_vote/src/models/poll_detail.dart';
import 'package:rousseau_vote/src/models/poll_detail_arguments.dart';
import 'package:rousseau_vote/src/network/graphql/graphql_queries.dart';
import 'package:rousseau_vote/src/network/handlers/vote_network_handler.dart';
import 'package:rousseau_vote/src/providers/vote_options_provider.dart';
import 'package:rousseau_vote/src/screens/polls_screen.dart';
import 'package:rousseau_vote/src/util/graphql_util.dart';
import 'package:rousseau_vote/src/util/profile_util.dart';
import 'package:rousseau_vote/src/util/ui_util.dart';
import 'package:rousseau_vote/src/util/widget/vertical_space.dart';
import 'package:rousseau_vote/src/widgets/core/conditional_widget.dart';
import 'package:rousseau_vote/src/widgets/core/icon_text_screen.dart';
import 'package:rousseau_vote/src/widgets/dialog/confirm_vote_dialog.dart';
import 'package:rousseau_vote/src/widgets/dialog/dismissable_dialog.dart';
import 'package:rousseau_vote/src/widgets/dialog/loading_dialog.dart';
import 'package:rousseau_vote/src/widgets/errors/error_page_widget.dart';
import 'package:rousseau_vote/src/widgets/graphql_query_widget.dart';
import 'package:rousseau_vote/src/widgets/loading_indicator.dart';
import 'package:rousseau_vote/src/widgets/logged_screen.dart';
import 'package:rousseau_vote/src/widgets/profile/badge_image.dart';
import 'package:rousseau_vote/src/widgets/rousseau_animated_screen.dart';
import 'package:rousseau_vote/src/widgets/vote/poll_details_body.dart';

class PollDetailsScreen extends StatelessWidget {
  const PollDetailsScreen(this.arguments);

  static const String ROUTE_NAME = '/poll_details';

  final PollDetailArguments arguments;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> variables = HashMap<String, dynamic>();
    variables.putIfAbsent('pollId', () => arguments.pollId);
    return ChangeNotifierProvider<VoteOptionsProvider>(
      create: (BuildContext context) => VoteOptionsProvider(),
      child: Consumer<VoteOptionsProvider>(
        builder: (BuildContext context, value, child) => LoggedScreen(
          GraphqlQueryWidget<PollDetail>(
            query: pollDetail,
            variables: variables,
            builderSuccess: (PollDetail pollDetail) =>
                _page(context, pollDetail: pollDetail),
            builderError: (List<GraphQLError> errors) =>
                _page(context, errors: errors),
            builderLoading: () => _page(context, isLoading: true),
          ),
        ),
      ),
    );
  }

  Widget _page(BuildContext context,
      {PollDetail pollDetail,
      bool isLoading = false,
      List<GraphQLError> errors}) {
    if (pollDetail != null) {
      Provider.of<VoteOptionsProvider>(context, listen: false)
          .onPollFetched(pollDetail.poll);
    }
    return RousseauAnimatedScreen(
      extendedAppBar: _header(context,
          pollDetail: pollDetail, isLoading: isLoading, errors: errors),
      appBar: const Image(
        image: WHITE_LOGO,
        height: 50,
      ),
      floatingActionButton: _floatingActionButton(context),
      body: _body(context,
          pollDetail: pollDetail, isLoading: isLoading, errors: errors),
      backgroundColor: BACKGROUND_GREY,
    );
  }

  Widget _header(BuildContext context,
      {PollDetail pollDetail,
      bool isLoading = false,
      List<GraphQLError> errors}) {
    if (isLoading || errors != null || pollDetail == null) {
      return Container(
        height: 200,
      );
    }
    final Poll poll = pollDetail.poll;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: Column(
        children: <Widget>[
          const VerticalSpace(60),
          Text(
            poll.title,
            maxLines: 3,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const Padding(
              padding:
                  EdgeInsets.only(left: 70, right: 70, top: 10, bottom: 10),
              child: Divider(
                thickness: 2,
                color: Colors.white,
              )),
          Text(
            poll.description,
            maxLines: 10,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const VerticalSpace(40),
//        Padding(padding: const EdgeInsets.only(left: 70, right: 70, top: 10, bottom: 10), child: Divider(thickness: 2, color: Colors.white,)),
//        Text(
//          RousseauLocalizations.getTextPlualized(context, 'vote-preferences-v2-s', 'vote-preferences-v2-p', poll.maxSelectableOptionsNumber),
//          style: TextStyle(
//              color: Colors.white,
//              fontWeight: FontWeight.w300,
//              fontSize: 15),
//          textAlign: TextAlign.center,
//        )
        ],
      ),
    );
  }

  Widget _floatingActionButton(BuildContext context) {
    return Provider.of<VoteOptionsProvider>(context, listen: false)
            .hasSelectedOptions()
        ? Container(
            width: 150,
            height: 150,
            child: FittedBox(
                child: FloatingActionButton.extended(
              label:
                  Text(RousseauLocalizations.getText(context, 'vote-button')),
              icon: const Icon(Icons.send),
              onPressed: () => _onSend(context),
            )))
        : null;
  }

  void _onSend(BuildContext context) {
    final VoteOptionsProvider provider =
        Provider.of<VoteOptionsProvider>(context, listen: false);
    _showDialog(
        context,
        ConfirmVoteDialog(
            selectedOptions: provider.getSelectedOptions(),
            remainingOptions: provider.remainingOptions(),
            pollType: provider.getPollType(),
            onConfirm: () {
              Navigator.of(context).pop();
              _onVoteConfirm(context);
            }));
  }

  void _onVoteConfirm(BuildContext context) {
    final VoteNetworkHandler voteNetworkHandler = getIt<VoteNetworkHandler>();
    final VoteOptionsProvider provider =
        Provider.of<VoteOptionsProvider>(context, listen: false);
    _onVoteConfirmLoading(context);
    voteNetworkHandler
        .submitVote(arguments.pollId, provider.getSelectedOptions())
        .then((QueryResult result) {
      if (result.success) {
        _onVoteConfirmSuccess(context);
      } else {
        _onVoteConfirmError(context);
      }
    }).catchError((dynamic object) => _onVoteConfirmError(context));
  }

  void _onVoteConfirmLoading(BuildContext context) {
    _showDialog(
        context,
        const LoadingDialog(
          titleKey: 'vote-confirm-sending',
        ));
  }

  void _onVoteConfirmSuccess(BuildContext context) {
    Navigator.of(context).pop();
    final Widget body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const VerticalSpace(30),
        const Icon(
          Icons.done_all,
          color: Colors.green,
        ),
        Text(
          RousseauLocalizations.getText(context, 'vote-already-done'),
          textAlign: TextAlign.center,
        )
      ],
    );
    final List<FlatButton> buttons = <FlatButton>[
      FlatButton(
        child: Text(
          RousseauLocalizations.getText(context, 'back-home'),
        ),
        onPressed:
            openRouteAction(context, PollsScreen.ROUTE_NAME, replace: true),
      )
    ];
    final Widget dialog = AlertDialog(
      content: SingleChildScrollView(
        child: body,
      ),
      actions: buttons,
    );
    _showDialog(context, dialog);
  }

  void _onVoteConfirmError(BuildContext context) {
    Navigator.of(context).pop();
    final Widget body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const VerticalSpace(30),
        const Icon(Icons.cloud_off),
        Text(
          RousseauLocalizations.getText(context, 'error-network'),
          textAlign: TextAlign.center,
        )
      ],
    );
    _showDialog(context, DismissableDialog(body: body));
  }

  void _showDialog(BuildContext context, Widget dialog) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => dialog);
  }

  Widget _body(BuildContext context,
      {PollDetail pollDetail,
      bool isLoading = false,
      List<GraphQLError> errors}) {
    if (isLoading) {
      return const LoadingIndicator();
    }
    if (errors != null) {
      return const ErrorPageWidget();
    }
    final Poll poll = pollDetail.poll;
    if (poll.closed) {
      final IconData iconData =
          poll.alreadyVoted ? Icons.event_available : Icons.event_busy;
      final String messageKey = poll.alreadyVoted
          ? 'poll-closed-already-voted'
          : 'poll-closed-did-not-vote';
      return IconTextScreen(
        iconData: iconData,
        messageKey: messageKey,
      );
    }

    if (poll.alreadyVoted) {
      return const IconTextScreen(
        iconData: Icons.event_available,
        messageKey: 'poll-voted',
        textColor: Colors.green,
        iconColor: Colors.green,
      );
    }

    if (poll.open && !poll.hasRequirements) {
      return const IconTextScreen(
        iconData: Icons.error_outline,
        messageKey: 'poll-alert',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ConditionalWidget(
            condition: poll.isCandidatePoll,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 45, left: 5, right: 5),
              child: Column(
                children: <Widget>[_searchBar(context), const VerticalSpace(30), _meritsFilter(context)],
              ),
            ),
          ),
          PollDetailsBody(poll),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    final VoteOptionsProvider provider = Provider.of(context);
    return TextField(
      keyboardType: TextInputType.text,
      onChanged: (String value) {
        provider.onSearchChanged(value);
      },
      decoration: InputDecoration(
          labelText:
              RousseauLocalizations.getText(context, 'vote-search-candidate'),
          hintText: RousseauLocalizations.getText(
              context, 'vote-search-candidate-hint'),
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)))),
    );
  }

  Widget _meritsFilter(BuildContext context) {
    final VoteOptionsProvider provider = Provider.of(context);
    final List<Widget> badges = <Widget>[];
    for (int i = 0; i < BADGES_NUMBER; i++) {
      final bool active = provider.isBadgeSelected(i);
      badges.add(Padding(
        padding: const EdgeInsets.only(left: 2, right: 2),
        child: BadgeImage(
          badgeNumber: i,
          size: 35,
          active: active,
          onTap: () => provider.onBadgeTapped(i),
        ),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: badges,
    );
  }
}
