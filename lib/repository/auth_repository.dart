import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:practice_flutter_googledocs_clone/constants.dart';
import 'package:practice_flutter_googledocs_clone/models/error_model.dart';
import 'package:practice_flutter_googledocs_clone/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(googleSignIn: GoogleSignIn(), client: Client()),
);
//ref: 다른 provider와 interaction할 때 매우 유용. interaction 할 일이 없으면 _ 로 두어도 됨.
//Provider 왜 쓰는가? : 인스턴스를 쉽게 생성하고, 테스트가 용이해지기 때문

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;

  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
  })  : _googleSignIn = googleSignIn,
        _client = client;

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
            final Map<String, dynamic> userAccMap =
                jsonDecode(res.body)['user'];

            final newUser = UserModel.fromMap(userAccMap);

            error = ErrorModel(error: null, data: newUser);
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
}
