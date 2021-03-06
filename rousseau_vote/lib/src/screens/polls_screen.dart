import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rousseau_vote/src/injection/injector_config.dart';
import 'package:rousseau_vote/src/models/poll_list.dart';
import 'package:rousseau_vote/src/network/graphql/graphql_queries.dart';
import 'package:rousseau_vote/src/prefetch/prefetch_manager.dart';
import 'package:rousseau_vote/src/widgets/ask_for_verification_widget.dart';
import 'package:rousseau_vote/src/widgets/graphql_query_widget.dart';
import 'package:rousseau_vote/src/widgets/loading_indicator.dart';
import 'package:rousseau_vote/src/widgets/polls_list_widget.dart';

import 'package:rousseau_vote/src/widgets/rousseau_logged_scaffold.dart';

class PollsScreen extends StatelessWidget {
  const PollsScreen();

  static const String ROUTE_NAME = '/polls';

  @override
  Widget build(BuildContext context) {
    return RousseauLoggedScaffold(
      body: GraphqlQueryWidget<PollList>(
        query: listPolls,
        fetchPolicy: FetchPolicy.cacheFirst,
        builderSuccess: (PollList pollList) {
          return AskForVerificationWidget(child: PollsListWidget(pollList));
        },
        builderLoading: () {
          return const LoadingIndicator();
        },
        builderError: (List<GraphQLError> error) {
          return Text(error.toString());
        },
        pullToRefresh: true,
      )
    );
  }
}
