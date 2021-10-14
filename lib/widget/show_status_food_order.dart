import 'dart:convert';

import 'package:chouayeefood/model/order_model.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';

class ShowStatusFoodOrder extends StatefulWidget {
  @override
  _ShowStatusFoodOrderState createState() => _ShowStatusFoodOrderState();
}

class _ShowStatusFoodOrderState extends State<ShowStatusFoodOrder> {
  String idUser;
  bool statusOrder = true;
  List<OrderModel> orderModels = [];
  List<List<String>> listMenuFoods = [];
  List<List<String>> listPrices = [];
  List<List<String>> listAmounts = [];
  List<List<String>> listSums = [];
  List<int> totalInts = [];
  List<int> statusInts = [];

  //work in initState before Widget build
  @override
  void initState() {
    super.initState();
    findUser();
  }

  @override
  Widget build(BuildContext context) {
    return statusOrder ? buildNoneOrder() : buildContent();
  }

  Widget buildContent() => ListView.builder(
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: orderModels.length,
        itemBuilder: (context, index) => Column(
          children: [
            MyStyle().mySizebox(),
            buildNameShop(index),
            buildDateTimeOrder(index),
            buildDistance(index),
            buildTransport(index),
            buildHead(),
            buildListViewMenuFood(index),
            Divider(),
            buildTotal(index),
            MyStyle().mySizebox(),
            buildStepIndicator(statusInts[index]),
            MyStyle().mySizebox(),
          ],
        ),
      );

  Widget buildStepIndicator(int index) => Column(
        children: [
          StepsIndicator(lineLength: 80,
            selectedStep: index,
            nbSteps: 4,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('ສັ່ງຊື້'),
              Text('ແຕ່ງອາຫານ'),
              Text('ຈັດສົ່ງ'),
              Text('ສຳເລັດ'),
            ],
          ),
        ],
      );

  Widget buildTotal(int index) => Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyStyle().showTitleH3Red('ລວມລາຄາທັງໝົດ:  '),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3Purple(
              totalInts[index].toString(),
            ),
          ),
        ],
      );

  ListView buildListViewMenuFood(int index) => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: listMenuFoods[index].length,
        itemBuilder: (context, index2) => Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(listMenuFoods[index][index2]),
            ),
            Expanded(
              flex: 1,
              child: Text(listPrices[index][index2]),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(listAmounts[index][index2]),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(listSums[index][index2]),
            ),
          ],
        ),
      );

  Container buildHead() {
    return Container(
      padding: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(color: Colors.grey[400]),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: MyStyle().showTitleH3White('ລາຍການອາຫານ'),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3White('ລາຄາ'),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3White('ຈຳນວນ'),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3White('ລວມ'),
          ),
        ],
      ),
    );
  }

  Row buildTransport(int index) {
    return Row(
      children: [
        MyStyle().showTitleH3Purple(
            'ຄ່າຂົນສົ່ງ: ${orderModels[index].transport} ກີບ'),
      ],
    );
  }

  Row buildDistance(int index) {
    return Row(
      children: [
        MyStyle()
            .showTitleH3Red('ໄລຍະທາງ: ${orderModels[index].distance} ກິໂລແມັດ'),
      ],
    );
  }

  Row buildDateTimeOrder(int index) {
    return Row(
      children: [
        MyStyle()
            .showTitleH3('ວັນເວລາສັ່ງຊື້: ${orderModels[index].orderDateTime}'),
      ],
    );
  }

  Row buildNameShop(int index) {
    return Row(
      children: [
        MyStyle().showTitleH2(orderModels[index].nameShop),
      ],
    );
  }

  Center buildNoneOrder() => Center(
        child: Text('ທ່ານຍັງບໍເຄີຍສັ່ງຊື້ອາຫານ'),
      );

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idUser = preferences.getString('id');
    print('idUser = $idUser');
    readOrderFromIdUser();
  }

  Future<Null> readOrderFromIdUser() async {
    if (idUser != null) {
      String url =
          '${MyConstant().domain}/chouayeefood/getOrderWhereIdUser.php?isAdd=true&idUser=$idUser';

      Response response = await Dio().get(url);
      print('response ==> $response');
      if (response.toString() != 'null') {
        var result = json.decode(response.data);
        for (var map in result) {
          OrderModel model = OrderModel.fromJson(map);
          List<String> menuFoods = changeArray(model.nameFood);
          List<String> prices = changeArray(model.price);
          List<String> amounts = changeArray(model.amount);
          List<String> sums = changeArray(model.sum);
          // print('menuFoods ==>> $menuFoods');
          
          int status = 0;
          switch (model.status) {
            case 'UserOrder':
              status = 0;
              break;
            case 'ShopCooking':
              status = 1;
              break;
            case 'RiderHandle':
              status = 2;
              break;
            case 'Finish':
              status = 3;
              break;
            default:
          }

          int total = 0;
          for (var string in sums) {
            total = total + int.parse(string.trim());
          }

          print('total = $total');

          setState(() {
            statusOrder = false;
            orderModels.add(model);
            listMenuFoods.add(menuFoods);
            listPrices.add(prices);
            listAmounts.add(amounts);
            listSums.add(sums);
            totalInts.add(total);
            statusInts.add(status);
          });
        }
      }
    }
  }

  List<String> changeArray(String string) {
    List<String> list = [];
    String myString = string.substring(1, string.length - 1);
    print('myString ==> $myString');
    list = myString.split(',');
    int index = 0;
    for (var string in list) {
      list[index] = string.trim();
      index++;
    }
    return list;
  }
}
