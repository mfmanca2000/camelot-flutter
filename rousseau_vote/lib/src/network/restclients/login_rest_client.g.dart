// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_rest_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _LoginRestClient implements LoginRestClient {
  _LoginRestClient(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    this.baseUrl ??=
        'https://sso.rousseau.movimento5stelle.it/auth/realms/rousseau';
  }

  final Dio _dio;

  String baseUrl;

  @override
  initLogin(nonce, state,
      {clientId = KEYCLOAK_CLIENT_ID,
      redirectUri = KEYCLOAK_REDIRECT_URI,
      responseMode = 'fragment',
      responseType = 'code',
      scope = 'openid email profile'}) async {
    ArgumentError.checkNotNull(nonce, 'nonce');
    ArgumentError.checkNotNull(state, 'state');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'nonce': nonce,
      r'state': state,
      r'client_id': clientId,
      r'redirect_uri': redirectUri,
      r'response_mode': responseMode,
      r'response_type': responseType,
      r'scope': scope
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/protocol/openid-connect/auth',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = InitLoginResponse.fromJson(_result.data);
    return value;
  }

  @override
  login(sessionCode, execution, tabId, body,
      {clientId = KEYCLOAK_CLIENT_ID}) async {
    ArgumentError.checkNotNull(sessionCode, 'sessionCode');
    ArgumentError.checkNotNull(execution, 'execution');
    ArgumentError.checkNotNull(tabId, 'tabId');
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'session_code': sessionCode,
      r'execution': execution,
      r'tab_id': tabId,
      r'client_id': clientId
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body ?? <String, dynamic>{});
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/login-actions/authenticate',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = CredentialsLoginResponse.fromJson(_result.data);
    return value;
  }

  @override
  submitTwoFactorCode(sessionCode, execution, tabId, body,
      {clientId = KEYCLOAK_CLIENT_ID}) async {
    ArgumentError.checkNotNull(sessionCode, 'sessionCode');
    ArgumentError.checkNotNull(execution, 'execution');
    ArgumentError.checkNotNull(tabId, 'tabId');
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'session_code': sessionCode,
      r'execution': execution,
      r'tab_id': tabId,
      r'client_id': clientId
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body ?? <String, dynamic>{});
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/login-actions/authenticate',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = CredentialsLoginResponse.fromJson(_result.data);
    return value;
  }

  @override
  getToken(body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body ?? <String, dynamic>{});
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/protocol/openid-connect/token',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = TokenResponse.fromJson(_result.data);
    return value;
  }
}
