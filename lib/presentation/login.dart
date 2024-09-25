import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/devices/devices_bloc.dart';
import '../data/api.dart';
import '../utilities/util.dart';
import 'home_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 1000);

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      /*if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return "user exist";*/
      return "";
    });
  }

  void userValidator(LoginData data) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      userType: LoginUserType.name,
      userValidator: (username) {
        if (username!.isEmpty) {
          return "please input username";
        }
        return null;
      },
      title: 'Dideban',
      logo: const AssetImage('images/logo.png'),
      onLogin: (data) async {
        final authResult = await API.userAuthenticate(data.name,data.password);

        if(authResult != null){
            Util.copyToSecureStorage("password", data.password);
            final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            final SharedPreferences prefs = await _prefs;
            prefs.setString('userName', data.name);
            prefs.setString('userId', authResult.id.toString());

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    BlocProvider(
                      create: (context) => DevicesBloc()
                        ..add(FetchAllDevices(authResult.id.toString()),),
                      child: const Home(),
                    ),
              ),
            );
        }else{
          return "user name or password is incorrect";
        }

      },
      onSignup: _signupUser,
      onRecoverPassword: _recoverPassword,
    );
  }
}