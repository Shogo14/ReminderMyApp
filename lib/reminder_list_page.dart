// チャット画面用Widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/user_state.dart';

import 'add_reminder_page.dart';
import 'login_page.dart';

class ReminderPage extends StatelessWidget {
  // 引数からユーザー情報を受け取れるようにする
  ReminderPage(this.user);
  // ユーザー情報
  final User user;

  @override
  Widget build(BuildContext context) {
    // ユーザー情報を受け取る
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('リマインダー'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              // ログアウト処理
              // 内部で保持しているログイン情報等が初期化される
              // （現時点ではログアウト時はこの処理を呼び出せばOKと、思うぐらいで大丈夫です）
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移＋チャット画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'),
          ),
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: ReminderLists(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddReminderPage(user);
            }),
          );
        },
      ),
    );
  }

  StreamBuilder ReminderLists() {
    return StreamBuilder<QuerySnapshot>(
      // 投稿メッセージ一覧を取得（非同期処理）
      // 投稿日時でソート
      stream: FirebaseFirestore.instance
          .collection('reminders')
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        // データが取得できた場合
        if (snapshot.hasData) {
          final Iterable<DocumentSnapshot> documents =
              snapshot.data.docs.where((doc) => doc['uid'] == user.uid);
          // 取得した投稿メッセージ一覧を元にリスト表示
          return ListView(
            children: documents.map((document) {
              IconButton deleteIcon;
              deleteIcon = IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  // 投稿メッセージのドキュメントを削除
                  await FirebaseFirestore.instance
                      .collection('reminders')
                      .doc(document.id)
                      .delete();
                },
              );
              IconButton updateIcon;
              updateIcon = IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  // TODO:
                  print('update');
                },
              );
              return Card(
                child: ListTile(
                  title: Text(document['title']),
                  subtitle: Text('店舗名：' + document['shop']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      updateIcon,
                      deleteIcon,
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
        // データが読込中の場合
        return Center(
          child: Text('読込中...'),
        );
      },
    );
  }
}
