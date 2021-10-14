import 'dart:convert';

import 'package:chouayeefood/model/food_model.dart';
import 'package:chouayeefood/screens/add_food_menu.dart';
import 'package:chouayeefood/screens/edit_food_menu.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListFoodMenuShop extends StatefulWidget {
  @override
  _ListFoodMenuShopState createState() => _ListFoodMenuShopState();
}
//have a problem

class _ListFoodMenuShopState extends State<ListFoodMenuShop> {
  bool loadStatus = true; // Process load JSon
  bool status = true; // Have data
  List<FoodModel> foodModels = [];

  @override
  void initState() {
    super.initState();
    readFoodMenu();
  }

  Future<Null> readFoodMenu() async {
    if (foodModels.length != 0) {
      foodModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');
    print('idShop = $idShop');

    String url =
        '${MyConstant().domain}/chouayeefood/getFoodWhereIdShop.php?isAdd=true&idShop=$idShop';
    await Dio().get(url).then((value) {
      setState(() {
        loadStatus = false;
      });

      if (value.toString() != 'null') {
        // print('value ==>> $value');

        var result = json.decode(value.data);
        // print('result ==>> $result');
        for (var map in result) {
          FoodModel foodModel = FoodModel.fromJson(map);
          setState(() {
            foodModels.add(foodModel);
          });
        }
      } else {
        setState(() {
          status = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        loadStatus ? MyStyle().showProgress() : showContent(),
        addMenuButton(),
      ],
    );
  }

  Widget showContent() {
    return status
        ? showListFood()
        : Center(
            child: Text('ຍັງບໍມີລາຍການອາຫານ'),
          );
  }

  Widget showListFood() => ListView.builder(
        itemCount: foodModels.length,
        itemBuilder: (context, index) => Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.4,
              child: Image.network(
                '${MyConstant().domain}${foodModels[index].pathImage}',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.4,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(foodModels[index].nameFood,
                        style: MyStyle().mainTitle),
                    Text('ລາຄາ ${foodModels[index].price} ກີບ',
                        style: MyStyle().mainH2Title),
                    Text(foodModels[index].detail),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            MaterialPageRoute route = MaterialPageRoute(
                              builder: (context) => EditFoodMenu(foodModel: foodModels[index],),
                            );
                            Navigator.push(context, route)
                                .then((value) => readFoodMenu());
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => deleteFood(foodModels[index]),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Future<Null> deleteFood(FoodModel foodModel) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: MyStyle()
            .showTitleH2('ທ່ານຕ້ອງການລຶບເມນູ ${foodModel.nameFood} ບໍ?'),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  String url =
                      '${MyConstant().domain}/chouayeefood/deleteFoodWhereId.php?isAdd=true&id=${foodModel.id}';
                  await Dio().get(url).then((value) => readFoodMenu());
                },
                child: Text('ຢືນຢັນ'),
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ຍັງບໍ່ລືບ'))
            ],
          )
        ],
      ),
    );
  }

  Widget addMenuButton() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 16.0, right: 16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => AddFoodMenu(),
                    );
                    Navigator.push(context, route)
                        .then((value) => readFoodMenu());
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ],
          ),
        ],
      );
}
