// 投稿画面用Widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'user_state.dart';

class AddReminderPage extends StatefulWidget {
  // 引数からユーザー情報を受け取る
  AddReminderPage(this.user);
  // ユーザー情報
  final User user;
  @override
  _AddReminderPageState createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  // リマインダー名
  String reminderTitle = '';
  // 店舗名
  String shop = '';
  // 住所名
  String address = '';
  // フォーカス管理用のFocusNode
  final reminderFocus = FocusNode();
  final shopFocus = FocusNode();
  final addressFocus = FocusNode();
  final submitReminderFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // ユーザー情報を受け取る
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('リマインダー登録'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 新規リマインダー入力
                reminderFormField(context),
                // 店舗名入力
                shopFormField(context),
                // 住所入力
                addressFormField(context),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Text('登録'),
                    focusNode: submitReminderFocus,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        await addReminder(user);
                        // 1つ前の画面に戻る
                        Navigator.of(context).pop();
                      }
                      print('no reminder');
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField reminderFormField(BuildContext context) {
    // 新規リマインダー入力
    return TextFormField(
      decoration: InputDecoration(labelText: 'リマインダー名'),
      // 複数行のテキスト入力
      keyboardType: TextInputType.multiline,
      autofocus: true,
      focusNode: reminderFocus,
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(shopFocus);
      },
      validator: (String value) {
        return ReminderValidation(value);
      },
      onChanged: (String value) {
        setState(() {
          reminderTitle = value;
        });
      },
    );
  }

  TextFormField shopFormField(BuildContext context) {
    // 店舗名入力
    return TextFormField(
      decoration: InputDecoration(labelText: '店舗名'),
      // 複数行のテキスト入力
      keyboardType: TextInputType.multiline,
      focusNode: shopFocus,
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(addressFocus);
      },
      validator: (String value) {
        return ShopValidation(value);
      },
      onChanged: (String value) {
        setState(() {
          shop = value;
        });
      },
    );
  }

  TextFormField addressFormField(BuildContext context) {
    // 住所入力
    return TextFormField(
      decoration: InputDecoration(labelText: '住所'),
      // 複数行のテキスト入力
      keyboardType: TextInputType.multiline,
      // 最大3行
      maxLines: 3,
      minLines: 1,
      focusNode: addressFocus,
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(submitReminderFocus);
      },
      validator: (String value) {
        return ShopValidation(value);
      },
      onChanged: (String value) {
        setState(() {
          address = value;
        });
      },
    );
  }

  Future addReminder(User user) async {
    final date = DateTime.now().toLocal().toIso8601String(); // 現在の日時
    final uid = user.uid; // ログインユーザーのuid
    // 新規リマインダー用ドキュメント作成
    await FirebaseFirestore.instance
        .collection('reminders') // コレクションID指定
        .doc() // ドキュメントID自動生成
        .set({
      'title': reminderTitle,
      'shop': shop,
      'address': address,
      'uid': uid,
      'date': date
    });
  }

  ReminderValidation(String reminder) {
    String result;
    if (reminder.isEmpty) {
      result = 'リマインダーを入力してください。';
    } else {
      result = null;
    }
    return result;
  }

  ShopValidation(String shop) {
    String result;
    if (shop.isEmpty) {
      result = '店舗名を入力してください。';
    } else {
      result = null;
    }
    return result;
  }
}
