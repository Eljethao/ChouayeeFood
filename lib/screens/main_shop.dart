import 'dart:io';

import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:chouayeefood/utility/signout_process.dart';
import 'package:chouayeefood/widget/information_shop.dart';
import 'package:chouayeefood/widget/list_food_menu_shop.dart';
import 'package:chouayeefood/widget/order_list_shop.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MainShop extends StatefulWidget {
  @override
  _MainShopState createState() => _MainShopState();
}

class _MainShopState extends State<MainShop> {
  //Field
  Widget currentWidget = OrderListShop();

  @override
  void initState() {
    super.initState();
    aboutNotification();
  }

  Future<Null> aboutNotification() async {
    if (Platform.isAndroid) {
      print('aboutNotification Work Android');

      FirebaseMessaging firebaseMessaging = FirebaseMessaging();
      await firebaseMessaging.configure(
        onLaunch: (message) async {
          print('Noti onLaunch');
        },
        onResume: (message) async {
          print('Noti onResume ${message.toString()}');
          String title = message['data']['title'];
          String body = message['data']['body'];
          normalDialog2(context, title, body);
        },
        onMessage: (message) async {
          print('Noti onMessage ${message.toString()}');
          String title = message['notification']['title'];
          String notiMessage = message['notification']['body'];
          normalDialog2(context, title, notiMessage);
        },
      );
    } else if (Platform.isIOS) {
      print('aboutNotification Work IOS');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Shop'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => signOutProcess(context),
          )
        ],
      ),
      drawer: showDrawer(),
      body: currentWidget,
    );
  }

  Drawer showDrawer() => Drawer(
        child: ListView(
          children: <Widget>[
            showHead(),
            homeMenu(),
            foodMenu(),
            informationMenu(),
            signOutMenu(),
          ],
        ),
      );

  ListTile homeMenu() => ListTile(
        leading: Icon(Icons.home),
        title: Text('ລາຍການອາຫານທີ່ລູກຄ້າສັ່ງ'),
        subtitle: Text('ລາຍການອາຫານທີ່ຍັງບໍໄດ້ເຮັດສົ່ງລູກຄ້າ'),
        onTap: () {
          setState(() {
            currentWidget = OrderListShop();
          });
          Navigator.pop(context);
        },
      );

  ListTile foodMenu() => ListTile(
        leading: Icon(Icons.fastfood),
        title: Text('ລາຍການອາຫານ'),
        subtitle: Text('ລາຍການອາຫານຂອງຮ້ານ'),
        onTap: () {
          setState(() {
            currentWidget = ListFoodMenuShop();
          });
          Navigator.pop(context);
        },
      );

  ListTile informationMenu() => ListTile(
        leading: Icon(Icons.info_rounded),
        title: Text('ລາຍລະອຽດຂອງຮ້ານ'),
        subtitle: Text('ລາຍລະອຽດຂອງຮ້ານພ້ອມ Edit'),
        onTap: () {
          setState(() {
            currentWidget = InformationShop();
          });
          Navigator.pop(context);
        },
      );

  ListTile signOutMenu() => ListTile(
        leading: Icon(Icons.exit_to_app),
        title: Text('Sign Out'),
        subtitle: Text('Sign out ແລະ ກັບໄປຮ້ານໜ້າຫຼັກ'),
        onTap: () => signOutProcess(context),
      );

  UserAccountsDrawerHeader showHead() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('shop.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text('Name Login'),
      accountEmail: Text('Login'),
    );
  }
}
