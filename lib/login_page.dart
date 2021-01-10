// ログイン画面用Widget
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/user_state.dart';

import 'chat_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // メッセージ表示用
  String infoText = '';
  // 入力したメールアドレス・パスワード
  String email = '';
  String password = '';

  // フォーカス管理用のFocusNode
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    final UserState userState = Provider.of<UserState>(context);
    User user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder App'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Reminder Appへようこそ！',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Container(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // メールアドレス入力
                    emailFormField(context),
                    // パスワード入力
                    passwordFormField(context),
                    Container(
                      padding: EdgeInsets.all(8),
                      // メッセージ表示
                      child: Text(infoText),
                    ),
                    Container(
                      width: double.infinity,
                      // ユーザー登録ボタン
                      child: SignUpButton(context, userState, user),
                    ),
                    Container(
                      width: double.infinity,
                      // ログイン登録ボタン
                      child: LoginButton(context, userState, user),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField emailFormField(BuildContext context) {
    // メールアドレス入力
    return TextFormField(
      decoration: InputDecoration(labelText: 'メールアドレス'),
      autofocus: true,
      focusNode: emailFocus,
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(passwordFocus);
      },
      validator: (String value) {
        return EmailValidation(value);
      },
      onChanged: (String value) {
        setState(() {
          email = value;
        });
      },
    );
  }

  TextFormField passwordFormField(BuildContext context) {
    // パスワード入力
    return TextFormField(
      decoration: InputDecoration(labelText: 'パスワード'),
      obscureText: true,
      focusNode: passwordFocus,
      validator: (String value) {
        return PasswordValidation(value);
      },
      onChanged: (String value) {
        setState(() {
          password = value;
        });
      },
    );
  }

  RaisedButton SignUpButton(
      BuildContext context, UserState userState, User user) {
    return RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: Text('ユーザー登録'),
      onPressed: () async {
        // バリデーションチェック
        if (_formKey.currentState.validate()) {
          try {
            user = await UserSignUp(userState, email, password);
            // チャット画面に遷移＋ログイン画面を破棄
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) {
                // ユーザー情報を渡す
                return ReminderPage(user);
              }),
            );
          } catch (e) {
            // ユーザー登録に失敗した場合
            setState(() async {
              infoText = "登録に失敗しました。";
            });
            print(e.messag);
          }
        }
      },
    );
  }

  OutlineButton LoginButton(
      BuildContext context, UserState userState, User user) {
    return OutlineButton(
      textColor: Colors.blue,
      child: Text('ログイン'),
      onPressed: () async {
        // バリデーションチェック
        if (_formKey.currentState.validate()) {
          try {
            user = await UserLogin(userState, email, password);
            // チャット画面に遷移＋ログイン画面を破棄
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) {
                // ユーザー情報を渡す
                return ReminderPage(user);
              }),
            );
          } catch (e) {
            // ログインに失敗した場合
            setState(() {
              infoText = "ログインに失敗しました。メールアドレスかパスワードに誤りがあります。";
            });
            print(e.message);
          }
        }
      },
    );
  }

  Future UserSignUp(UserState userState, email, password) async {
    // メール/パスワードでユーザー登録
    final FirebaseAuth auth = FirebaseAuth.instance;
    final UserCredential result = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print(email);
    final User user = result.user;
    // ユーザー情報を更新
    userState.setUser(user);
    return user;
  }

  Future UserLogin(UserState userState, email, password) async {
    // メール/パスワードでログイン
    final FirebaseAuth auth = FirebaseAuth.instance;
    final UserCredential result = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User user = result.user;
    // ユーザー情報を更新
    userState.setUser(user);

    return user;
  }

  EmailValidation(String email) {
    String result;
    if (email.isEmpty) {
      result = 'メールアドレスを入力してください。';
    } else if (email.indexOf('@') == -1) {
      result = '正しいメールアドレスを入力してください。';
    } else {
      result = null;
    }
    return result;
  }

  PasswordValidation(String password) {
    String result;
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    if (password.isEmpty) {
      result = 'パスワードを入力してください。';
    } else if (!RegExp(pattern).hasMatch(password)) {
      result = 'パスワードは半角英小文字大文字数字と記号をそれぞれ1種類以上含む8文字以上入力してください。';
    } else {
      result = null;
    }
    return result;
  }
}
