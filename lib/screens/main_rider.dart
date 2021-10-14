import 'dart:convert';
import 'dart:io';

import 'package:chouayeefood/model/order_model.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:chouayeefood/utility/signout_process.dart';
import 'package:chouayeefood/widget/rider_order_detail.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainRider extends StatefulWidget {
  //_callMethod(BuildContext context) => createState().readOrder();
  @override
  _MainRiderState createState() => _MainRiderState();
}

class _MainRiderState extends State<MainRider> {
  String nameUser;
  int menuIndex;

  Widget currentWidget;
  List<OrderModel> orderModels = [];

  @override
  void initState() {
    super.initState();
    findUser();
    readOrder();
    aboutNotification();
  }

  Future<Null> aboutNotification() async{
    if (Platform.isAndroid) {
      print('aboutNofication work Android');

      FirebaseMessaging firebaseMessaging = FirebaseMessaging();
      await firebaseMessaging.configure(
        onLaunch: (message) async{
          print('Noti onlaunch');
        },
        onResume: (message) async{
          print('Noti on Resume ${message.toString()}');
          String title = message['data']['title'];
          String body = message['data']['body'];
          normalDialog2(context, title, body).then((value) => readOrder());
        },
        onMessage: (message) async{
          print('Noti on Message ${message.toString()}');
          String title = message['notification']['title'];
          String notiMessage = message['notification']['body'];
          normalDialog2(context, title, notiMessage).then((value) => readOrder());
        },
      );    
    }else if(Platform.isIOS){
      print('notification work on IOS');
    }

  }

  Future<Null> readOrder() async {
    if (orderModels.length != 0) {
      orderModels.clear();
    }

    String url =
        '${MyConstant().domain}/chouayeefood/getShopOrderWhereStatus.php?isAdd=true&Status=ShopCooking';
    Response response = await Dio().get(url);
    // print('response ==>> $response');
    var result = json.decode(response.data);
    for (var map in result) {
      OrderModel model = OrderModel.fromJson(map);
      setState(() {
        orderModels.add(model);
      });
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
        title: Text(nameUser == null ? 'Main Rider' : '$nameUser Login'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => signOutProcess(context),
          )
        ],
      ),
      drawer: showDrawer(),
      body: orderModels.length == null
          ? MyStyle().showProgress()
          : buildContent(),
    );
  }

  Widget buildContent() => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: orderModels.length,
        itemBuilder: (context, index) => Column(
          children: [
            ListTile(
              title: Column(
                children: [
                  Row(
                    children: [
                      MyStyle().showTitleH2(orderModels[index].nameShop),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ໄລຍະທາງ: " + orderModels[index].distance + " ກິໂລແມັດ",
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        "ຄ່າສົ່ງ: " + orderModels[index].transport + "ກີບ",
                        style:
                            TextStyle(fontSize: 13, color: MyStyle().darkColor),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                MaterialPageRoute route = MaterialPageRoute(
                  builder: (context) =>
                      RiderOrderDetail(orderModel: orderModels[index]),
                );
                Navigator.push(context, route).then((value) => readOrder());
                menuIndex = index;
              },
            ),
            Divider(),
          ],
        ),
      );

  Drawer showDrawer() => Drawer(
        child: ListView(
          children: <Widget>[
            showHead(),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //menuListOrder(menuIndex),
                menuSignOut(),
              ],
            ),
          ],
        ),
      );

  // Widget menuListOrder(int index) {
  //   return ListTile(
  //     onTap: () {
  //       MaterialPageRoute route = MaterialPageRoute(
  //         builder: (context) =>
  //             RiderOrderDetail(orderModel: orderModels[index]),
  //       );
  //       Navigator.push(context, route).then((value) => readOrder());
  //     },
  //     leading: Icon(
  //       Icons.list,
  //       color: MyStyle().darkColor,
  //     ),
  //     title: Text('ລາຍການ Order ທີ່ຮັບມາ'),
  //     subtitle: Text(
  //       'ລາຍການ Order ທີ່ຍັງບໍໄດ້ສົ່ງ',
  //       style: TextStyle(color: MyStyle().darkColor),
  //     ),
  //   );
  // }

  Widget menuSignOut() {
    return ListTile(
      onTap: () => signOutProcess(context),
      leading: Icon(
        Icons.exit_to_app,
        color: Colors.red,
      ),
      title: Text(
        'ອອກຈາກລະບົບ',
        style: TextStyle(color: Colors.black),
      ),
      subtitle: Text(
        'ກົດອອກຈາກລະບົບທີ່ນີ້',
        style: TextStyle(color: MyStyle().darkColor),
      ),
    );
  }

  UserAccountsDrawerHeader showHead() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('rider.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text(
        nameUser == null ? 'Name Login' : '$nameUser Login',
        style: TextStyle(color: MyStyle().darkColor),
      ),
      accountEmail: Text(
        'Login',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
