import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practice_flutter_googledocs_clone/repository/auth_repository.dart';
import 'package:practice_flutter_googledocs_clone/colors.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    //위로 빼는 이유: context 호출에 await로 gap을 주면, gap 이후에 widget이 존재한다고 보장하지 못하기 때문에, context가 destroy되었을 수 있다.
    //context.mounted 로 체크하거나, await 전에 생성해 놓는다.

    final errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();

    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      //성공 응답에서 받은 데이터로 provider를 업데이트한다.

      navigator.replace('/');
    } else {
      sMessenger.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //WidgetRef ref: Provider 를 받아오기 위해 필요

    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => signInWithGoogle(ref, context),
          icon: Image.asset(
            'assets/images/g-logo-2.png',
            height: 20,
          ),
          label: const Text('Sign in with Google',
              style: TextStyle(color: kBlackColor)),
          style: ElevatedButton.styleFrom(
            backgroundColor: kWhiteColor,
            minimumSize: const Size(150, 50),
          ),
        ),
      ),
    );
  }
}
