import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rousseau_vote/src/models/poll_list.dart';
import 'package:rousseau_vote/src/network/graphql/graphql_queries.dart';
import 'package:rousseau_vote/src/widgets/graphql_query_widget.dart';
import 'package:rousseau_vote/src/widgets/loading_indicator.dart';
import 'package:rousseau_vote/src/widgets/poll_card.dart';

import 'package:rousseau_vote/src/widgets/rousseau_logged_scaffold.dart';

class PollsScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/';

  @override
  Widget build(BuildContext context) {
    return RousseauLoggedScaffold(GraphqlQueryWidget<PollList>(
      query: listPolls,
      builderSuccess: (PollList pollList) {
//          return Text(pollList.polls[0].title);
        return ListView.separated(
            padding: const EdgeInsets.all(30.0),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 30.0),
            itemCount: pollList.polls.length,
            itemBuilder: (BuildContext context, int index) =>
                PollCard(pollList.polls[index]));
      },
      builderLoading: () {
        return const LoadingIndicator();
      },
      builderError: (List<GraphQLError> error) {
        return Text(error.toString());
      },
    ));
  }
}
