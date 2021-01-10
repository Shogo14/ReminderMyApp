import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import 'user_state.dart';

void main() {
  // 最初に表示するWidget
  runApp(ReminderApp());
}

class ReminderApp extends StatelessWidget {
  // ユーザーの情報を管理するデータ
  final UserState userState = UserState();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserState>.value(
      value: userState,
      child: MaterialApp(
        // 右上に表示される"debug"ラベルを消す
        debugShowCheckedModeBanner: false,
        // アプリ名
        title: 'ReminderApp',
        theme: ThemeData(
          // テーマカラー
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // ログイン画面を表示
        home: LoginPage(),
      ),
    );
  }
}
