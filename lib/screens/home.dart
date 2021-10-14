import 'dart:convert';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:chouayeefood/model/user_model.dart';
import 'package:chouayeefood/screens/main_rider.dart';
import 'package:chouayeefood/screens/main_shop.dart';
import 'package:chouayeefood/screens/main_user.dart';
import 'package:chouayeefood/screens/signin.dart';
import 'package:chouayeefood/screens/signup.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<UserModel> userModels = [];
  List<Widget> shopCards = [];

  @override
  void initState() {
    super.initState();
    checkPreference();
    readShop();
  }

  Future<Null> readShop() async {
    String url =
        '${MyConstant().domain}/chouayeefood/getUserWhereChooseType.php?isAdd=true&ChooseType=Shop';
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      print('result ==>> $result');
      int index = 0;
      for (var map in result) {
        UserModel model = UserModel.fromJson(map);

        String nameShop = model.nameShop;
        if (nameShop.isNotEmpty) {
          setState(() {
            userModels.add(model);
            shopCards.add(createCard(model, index));
            index++;
          });
        }
      }
    });
  }

  Widget createCard(UserModel userModel, int index) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.0,
              height: 60.0,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    '${MyConstant().domain}${userModel.urlPicture}'),
              ),
            ),
            MyStyle().mySizebox(),
            MyStyle().showTitleH3(userModel.nameShop),
          ],
        ),
      ),
    );
  }

  Future<Null> checkPreference() async {
    try {
      FirebaseMessaging firebaseMessaging = FirebaseMessaging();
      String token = await firebaseMessaging.getToken();
      print('toke ====>>> $token');

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String chooseType = preferences.getString('ChooseType');
      String idLogin = preferences.getString('id');
      print('idLogin = $idLogin');

      if (idLogin != null && idLogin.isNotEmpty) {
        String url =
            '${MyConstant().domain}/chouayeefood/editTokenWhereId.php?isAdd=true&id=$idLogin&Token=$token';
        await Dio()
            .get(url)
            .then((value) => print('Update Token Success ####'));
      }

      if (chooseType != null && chooseType.isNotEmpty) {
        if (chooseType == 'User') {
          routeToService(MainUser());
        } else if (chooseType == 'Shop') {
          routeToService(MainShop());
        } else if (chooseType == 'Rider') {
          routeToService(MainRider());
        } else {
          normalDialog(context, 'Error User Type');
        }
      }
    } catch (e) {}
  }

  void routeToService(Widget myWidget) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: showDrawer(),
      body: Column(
        children: [
          Expanded(child: imageSlider()),
          Expanded(child: shopList()),
        ],
      ),
    );
  }

  ListView imageSlider() {
    return ListView(
      padding: EdgeInsets.only(top: 8.0),
      children: [
        SizedBox(
          height: 180.0,
          width: double.infinity,
          child: Carousel(
            dotSize: 4.0,
            dotSpacing: 15.0,
            indicatorBgPadding: 5.0,
            dotBgColor: Colors.transparent,
            images: [
              Image.asset(
                'images/slide1.jpg',
                fit: BoxFit.cover,
              ),
              Image.asset(
                'images/slide2.jpg',
                fit: BoxFit.cover,
              ),
              Image.asset(
                'images/slide3.jpg',
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Column(
              children: [
                Text(
                  'ຮ້ານອາຫານໃນລະບົບ',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget shopList() {
    return Container(
        child: shopCards.length == 0 ? MyStyle().showProgress(): GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      children: shopCards,
    ));
  }

  Drawer showDrawer() => Drawer(
        child: ListView(
          children: <Widget>[
            showHeadDrawer(),
            signInMenu(),
            signUpMenu(),
          ],
        ),
      );

  ListTile signInMenu() {
    return ListTile(
      leading: Icon(
        Icons.login,
        color: Colors.green,
      ),
      title: Text('Sign In'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => SignIn());
        Navigator.push(context, route);
      },
    );
  }

  ListTile signUpMenu() {
    return ListTile(
      leading: Icon(Icons.app_registration, color: Colors.blue),
      title: Text('Sign Up'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => SignUp());
        Navigator.push(context, route);
      },
    );
  }

  UserAccountsDrawerHeader showHeadDrawer() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('guest.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text('Guest'),
      accountEmail: Text('Please login'),
    );
  }
}
