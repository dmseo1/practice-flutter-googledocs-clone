import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:practice_flutter_googledocs_clone/constants.dart';
import 'package:practice_flutter_googledocs_clone/models/error_model.dart';
import 'package:practice_flutter_googledocs_clone/models/user_model.dart';
import 'package:practice_flutter_googledocs_clone/repository/local_storage_repository.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorageRepository: LocalStorageRepository(),
  ),
);
//ref: 다른 provider와 interaction할 때 매우 유용. interaction 할 일이 없으면 _ 로 두어도 됨.
//Provider 왜 쓰는가? : 인스턴스를 쉽게 생성하고, 테스트가 용이해지기 때문

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;

  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageRepository localStorageRepository,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ErrorModel> getUserData() async {
    ErrorModel error =
        ErrorModel(error: 'Some unexpected error occured', data: null);
    try {
      String? token = await _localStorageRepository.getToken();

      if (token != null) {
        final res = await _client.get(Uri.parse('$host/'), headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        });

        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromMap(
              jsonDecode(res.body)['user'],
            ).copyWith(
              token: token,
            );

            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);

            break;
        }
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error =
        ErrorModel(error: 'Some unexpected error occured', data: null);
    try {
      final user = await _googleSignIn.signIn();

      if (user != null) {
        final googleAuth = await user.authentication;
        final idToken = googleAuth.idToken;

        final res = await _client.post(Uri.parse('$host/api/signup'),
            body: jsonEncode({'idToken': idToken}),
            headers: {'Content-Type': 'application/json; charset=UTF-8'});

        switch (res.statusCode) {
          case 200:
            final parsedBody = jsonDecode(res.body);
            final newUser = UserModel.fromMap(
              parsedBody['user'],
            ).copyWith(
              token: parsedBody['token'],
            );

            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);

            break;
        }
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    _localStorageRepository.setToken('');
  }
}
