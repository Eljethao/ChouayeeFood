
import 'dart:io';

import 'package:chouayeefood/screens/show_cart.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:chouayeefood/utility/signout_process.dart';
import 'package:chouayeefood/widget/show_list_shop_all.dart';
import 'package:chouayeefood/widget/show_status_food_order.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainUser extends StatefulWidget {
  @override
  _MainUserState createState() => _MainUserState();
}

class _MainUserState extends State<MainUser> {
  String nameUser;

  Widget currentWidget;

  @override
  void initState() {
    super.initState();
    currentWidget = ShowListShopAll();
    findUser();
    aboutNotification();
  }

  Future<Null> aboutNotification() async{
    if(Platform.isAndroid){
      print('aboutNotification work on Android');

      FirebaseMessaging firebaseMessaging = FirebaseMessaging();
      await firebaseMessaging.configure(
        onLaunch: (message) async{
          print('Noti onLaunch');
        },
        onResume: (message)async{
          String title = message['data']['title'];
          String body = message['data']['body'];
          normalDialog3(context, title, body);
        },
        onMessage: (message) async{
          String title = message['notification']['title'];
          String notiMessage = message['notification']['body'];
          normalDialog3(context, title, notiMessage);
        },
      );
    }
  }


  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nameUser = preferences.getString('Name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nameUser == null ? 'Main User' : '$nameUser login'),
        actions: <Widget>[
          MyStyle().iconShowCart(context),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => signOutProcess(context),
          )
        ],
      ),
      drawer: showDrawer(),
      //showProgress turn turn turn
      body: currentWidget,
    );
  }

  Drawer showDrawer() => Drawer(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                showHead(),
                manuListShop(),
                menuCart(),
                menuStatusFoodOrder(),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                manuSignOut(),
              ],
            ),
          ],
        ),
      );

  ListTile manuListShop() {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          currentWidget = ShowListShopAll();
        });
      },
      leading: Icon(Icons.home),
      title: Text('ສະແດງຮ້ານຄ້າ'),
      subtitle: Text('ສະແດງຮ້ານຄ້າ ທີ່ສາມາດສັ່ງອາຫານໄດ້'),
    );
  }

  ListTile menuStatusFoodOrder() {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          currentWidget = ShowStatusFoodOrder();
        });
      },
      leading: Icon(Icons.fastfood),
      title: Text('ສະແດງລາຍການອາຫານທີ່ສັ່ງ'),
      subtitle: Text('ສະແດງລາຍການອາຫານທີ່ສັ່ງ ຫຼື ເບິ່ງສະຖານະຂອງອາຫານທີ່ສັ່ງ'),
    );
  }

  Widget manuSignOut() {
    return Container(
      decoration: BoxDecoration(color: Colors.red.shade700),
      child: ListTile(
        onTap: () => signOutProcess(context),
        leading: Icon(
          Icons.exit_to_app,
          color: Colors.white,
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'ການອອກຈາກແອັບ',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  UserAccountsDrawerHeader showHead() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('user.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text(
        nameUser == null ? 'Name Login' : nameUser,
        style: TextStyle(color: MyStyle().darkColor),
      ),
      accountEmail: Text(
        'Login',
        style: TextStyle(color: MyStyle().primaryColor),
      ),
    );
  }

  Widget menuCart() {
    return ListTile(
      leading: Icon(Icons.add_shopping_cart),
      title: Text('ກະຕ່າຂອງທ່ານ'),
      subtitle: Text('ລາຍການອາຫານ ທີ່ຢູ່ໃນກະຕ່າ ຍັງບໍໄດ້ສັ່ງຊື້'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route = MaterialPageRoute(
          builder: (context) => ShowCart(),
        );
        Navigator.push(context, route);
      },
    );
  }
}
