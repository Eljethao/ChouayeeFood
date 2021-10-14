import 'dart:convert';

import 'package:chouayeefood/model/user_model.dart';
import 'package:chouayeefood/screens/show_shop_food_menu.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ShowListShopAll extends StatefulWidget {
  @override
  _ShowListShopAllState createState() => _ShowListShopAllState();
}

class _ShowListShopAllState extends State<ShowListShopAll> {

  List<UserModel> userModels = [];
  List<Widget> shopCards = [];

  @override
  void initState() {
    super.initState();
    readShop();
  }

  Future<Null> readShop() async {
    String url =
        '${MyConstant().domain}/chouayeefood/getUserWhereChooseType.php?isAdd=true&ChooseType=Shop';
    await Dio().get(url).then((value) {
      // print('value = $value');
      var result = json.decode(value.data);
      int index = 0;
      for (var map in result) {
        UserModel model = UserModel.fromJson(map);

        String nameShop = model.nameShop;
        if (nameShop.isNotEmpty) {
          print('NameShop = ${model.nameShop}');
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
      onTap: () {
        print('You click index $index');
        MaterialPageRoute route = MaterialPageRoute(
          builder: (context) => ShowShopFoodMenu(
            userModel: userModels[index],
          ),
        );
        Navigator.push(context, route);
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.0,
              height: 80.0,
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

  @override
  Widget build(BuildContext context) {
    return  shopCards.length == 0
          ? MyStyle().showProgress()
          : GridView.extent(
              maxCrossAxisExtent: 295.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              children: shopCards,
            );
  }
}