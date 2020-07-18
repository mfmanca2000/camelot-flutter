import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rousseau_vote/src/injection/injector_config.dart';
import 'package:rousseau_vote/src/models/user/current_user.dart';
import 'package:rousseau_vote/src/network/graphql/graphql_queries.dart';
import 'package:rousseau_vote/src/store/token_store.dart';
import 'package:rousseau_vote/src/util/ui_util.dart';
import 'package:rousseau_vote/src/util/widget/vertical_space.dart';
import 'package:rousseau_vote/src/widgets/profile/badges_widget.dart';
import 'package:rousseau_vote/src/widgets/user/profile_picture.dart';

import '../graphql_query_widget.dart';

const double PROFILE_PICTURE_RADIUS = 30;

class CurrentUserCard extends StatelessWidget {
  const CurrentUserCard();

  @override
  Widget build(BuildContext context) {
    return GraphqlQueryWidget<CurrentUser>(
      query: currentUserShort,
      fetchPolicy: FetchPolicy.cacheFirst,
      builderSuccess: (CurrentUser currentUser) {
        return Column(
          children: <Widget>[
            _identitySection(context, currentUser),
            const VerticalSpace(10),
            BadgesWidget(currentUser.badges, 20, showInactive: false),
          ],
        );
      },
      builderLoading: () {
        return _placeholderWidget();
      },
      builderError: (List<GraphQLError> errors) {
        showSimpleSnackbar(context, 'error-profile-loading');
        return _placeholderWidget();
      },
    );
  }

  Widget _identitySection(BuildContext context, CurrentUser currentUser) {
    return InkWell(
      child: ListTile(
          leading: ProfilePicture(url: currentUser.getProfilePictureUrl(), radius: PROFILE_PICTURE_RADIUS),
          title: Text(
            currentUser.fullName,
            style: const TextStyle(fontSize: 20),
          ),
          subtitle: Text(currentUser.slug),
          onTap: () {
            Navigator.of(context).pop();
            if (currentUser.profile != null) {
              openProfile(context, currentUser.slug);
            } else {
              showSimpleSnackbar(context, 'message-profile-not-compiled');
            }
          }
      ),
    );
  }

  Widget _placeholderWidget() {
    final TokenStore tokenStore = getIt<TokenStore>();
    return ListTile(
      leading: const ProfilePicture(radius: PROFILE_PICTURE_RADIUS),
      title: Text(
        tokenStore.getUserFullName(),
        style: const TextStyle(fontSize: 20),
      ),
      subtitle: const Text(''),
    );
  }
}
