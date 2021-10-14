import 'package:chouayeefood/model/user_model.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/widget/about_shop.dart';
import 'package:chouayeefood/widget/show_menu_food.dart';
import 'package:flutter/material.dart';

class ShowShopFoodMenu extends StatefulWidget {
  final UserModel userModel;
  ShowShopFoodMenu({Key key, this.userModel}) : super(key: key);

  @override
  _ShowShopFoodMenuState createState() => _ShowShopFoodMenuState();
}

class _ShowShopFoodMenuState extends State<ShowShopFoodMenu> {
  UserModel userModel;
  List<Widget> listWidgets = [];
  int indexPage = 0;

  @override
  void initState() {
    super.initState();
    userModel = widget.userModel;
    listWidgets.add(AboutShop(
      userModel: userModel,
    ));
    listWidgets.add(ShowMenuFood(
      userModel: userModel,
    ));
  }

  BottomNavigationBarItem aboutShopNav() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.info_rounded),
      label: 'ລາຍລະອຽດຮ້ານ',
    );
  }

  BottomNavigationBarItem showMenuFoodNav() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.fastfood_outlined),
      label: 'ເມນູອາຫານ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [MyStyle().iconShowCart(context)],
        title: Text(userModel.nameShop),
      ),
      body: listWidgets.length == 0
          ? MyStyle().showProgress()
          : listWidgets[indexPage],
      bottomNavigationBar: showBottomNavigationBar(),
    );
  }

  BottomNavigationBar showBottomNavigationBar() => BottomNavigationBar(
        selectedItemColor: Colors.green,
        currentIndex: indexPage,
        onTap: (value) {
          setState(() {
            indexPage = value;
          });
        },
        items: <BottomNavigationBarItem>[
          aboutShopNav(),
          showMenuFoodNav(),
        ],
      );
}
