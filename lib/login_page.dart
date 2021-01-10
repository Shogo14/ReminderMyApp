// ログイン画面用Widget
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kindle/user_state.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    final UserState userState = Provider.of<UserState>(context);
    User user;
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // メールアドレス入力
              TextFormField(
                decoration: InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              // パスワード入力
              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText),
              ),
              Container(
                width: double.infinity,
                // ユーザー登録ボタン
                child: RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('ユーザー登録'),
                  onPressed: () async {
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
                  },
                ),
              ),
              Container(
                width: double.infinity,
                // ログイン登録ボタン
                child: OutlineButton(
                  textColor: Colors.blue,
                  child: Text('ログイン'),
                  onPressed: () async {
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
}
