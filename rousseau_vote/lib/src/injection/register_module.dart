import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:rousseau_vote/src/config/app_constants.dart';
import 'package:rousseau_vote/src/init/startup_initializer.dart';
import 'package:rousseau_vote/src/init/startup_prefetcher.dart';
import 'package:rousseau_vote/src/network/graphql/graphql_queries.dart';
import 'package:rousseau_vote/src/notifications/push_notifications_manager.dart';
import 'package:rousseau_vote/src/providers/blog_instant_article_provider.dart';
import 'package:rousseau_vote/src/store/token_store.dart';
import 'package:rousseau_vote/src/util/debug_util.dart';

import 'injector_config.dart';

@registerModule
abstract class RegisterModule {

  @singleton
  FlutterSecureStorage get flutterSecureStorage;

  // all the initializer here are going to be executed at startup time
  StartupInitializer get startupInitializer => StartupInitializer([
    getIt<TokenStore>(),
    StartupPrefetcher([listPolls, currentUserShort]),
    getIt<PushNotificationManager>(),
    getIt<BlogInstantArticleProvider>(),
  ], 3000);

  FirebaseMessaging get firebaseMessaging => FirebaseMessaging();

  @singleton
  @Injectable(as: PushNotificationManager)
  PushNotificationManager getPushNotificationManager() {
    if (isInDebugMode) {
      return getIt<NoOpPushNotificationManager>();
    }
    return getIt<FirebaseNotificationManager>();
  }

  @singleton
  GraphQLClient getGraphQLClient() {
    final HttpLink httpLink = HttpLink(
      uri: GRAPHQL_URL,
    );
    final AuthLink authLink = AuthLink(
        getToken: () async {
          final TokenStore tokenStore = getIt<TokenStore>();
          final String accessToken = await tokenStore.getAccessToken();
          return 'Bearer $accessToken';
        }
    );
    final Link link = authLink.concat(httpLink);
    return GraphQLClient(
      link: link,
      // hack not to cache nodes but only whole queries not to have conflicts with json serializable
      cache: OptimisticCache(dataIdFromObject: (Object object) => null),
    );
  }

  ValueNotifier<GraphQLClient> getGraphqlClientNotifier(@factoryParam BuildContext buildContext) {
    return ValueNotifier<GraphQLClient>(getIt<GraphQLClient>(param1: buildContext));
  }

  @singleton
  @RegisterAs(Dio)
  DioForNative dioForNative() {
    final DioForNative dio = DioForNative();
    final CookieManager cookieManager = CookieManager(DefaultCookieJar());
    dio.interceptors.add(cookieManager);
    dio.interceptors.add(InterceptorsWrapper(
      // ignore: always_specify_types
        onResponse: (Response response) {
          if (response.data != null && response.data is String) {
            final Map<String, dynamic> decodedData = jsonDecode(response.data);
            response.data = decodedData;
          }
          return response;
        }
    ));
    return dio;
  }
}