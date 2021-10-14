import 'dart:convert';

import 'package:chouayeefood/model/order_model.dart';
import 'package:chouayeefood/model/user_model.dart';
import 'package:chouayeefood/utility/my_api.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class OrderListShop extends StatefulWidget {
  @override
  _OrderListShopState createState() => _OrderListShopState();
}

class _OrderListShopState extends State<OrderListShop> {
  String idShop;
  String strStatus;
  List<OrderModel> orderModels = [];
  List<List<String>> listNameFoods = [];
  List<List<String>> listPrices = [];
  List<List<String>> listAmounts = [];
  List<List<String>> listSums = [];
  List<int> totals = [];

  @override
  void initState() {
    super.initState();
    findIdShopAndReadOrder();
  }

  Future<Null> findIdShopAndReadOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idShop = preferences.getString(MyConstant().keyId);
    print('idShop = $idShop');

    String path =
        '${MyConstant().domain}/chouayeefood/getOrderWhereidShop.php?isAdd=true&idShop=$idShop';
    await Dio().get(path).then((value) {
      // print('value ==>> $value');
      var result = json.decode(value.data);
      // print('result ==>> $result');
      for (var item in result) {
        OrderModel model = OrderModel.fromJson(item);
        // print('OrderDateTime ==>> ${model.orderDateTime}');

        List<String> nameFoods = MyAPI().createStringarray(model.nameFood);
        List<String> prices = MyAPI().createStringarray(model.price);
        List<String> amounts = MyAPI().createStringarray(model.amount);
        List<String> sums = MyAPI().createStringarray(model.sum);

        int total = 0;
        for (var item in sums) {
          total += int.parse(item);
        }

        setState(() {
          orderModels.add(model);
          listNameFoods.add(nameFoods);
          listPrices.add(prices);
          listAmounts.add(amounts);
          listSums.add(sums);
          totals.add(total);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orderModels.length == 0
          ? MyStyle().showProgress()
          : ListView.builder(
              itemCount: orderModels.length,
              itemBuilder: (context, index) => Card(
                color: index % 2 == 0
                    ? Colors.lime.shade100
                    : Colors.lime.shade400,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyStyle().showTitleH2(orderModels[index].nameUser),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: MyStyle()
                                .showTitleH3(orderModels[index].orderDateTime),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                MyStyle().showTitleH3('ສະຖານະ: '),
                                Text(
                                  orderModels[index].status != 'ShopCooking' && orderModels[index].status != 'Finish'
                                      ? strStatus = 'ຍັງບໍໄດ້ຮັບ Order'
                                      : strStatus = 'ຮັບ Order ແລ້ວ',
                                  style: TextStyle(
                                      color: Colors.red.shade600, fontSize: 12),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      buildTitle(),
                      ListView.builder(
                        itemCount: listNameFoods[index].length,
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index2) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(listNameFoods[index][index2]),
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
                        ),
                      ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MyStyle().showTitleH2('ລວມລາຄາ: '),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: MyStyle()
                                .showTitleH3Red(totals[index].toString()),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                confirmCalcelOrder(
                                  orderModels[index].idUser,
                                  orderModels[index].id,                      
                                );
                              },
                              icon: Icon(Icons.cancel),
                              label: Text('ຍົກເລີກ')),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                updateOrderStatus(orderModels[index].id);
                                notificationToRider();
                                setState(() {
                                  findIdShopAndReadOrder();
                                });
                              },
                              icon: Icon(Icons.restaurant),
                              label: Text('ຮັບ Order')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<Null> confirmCalcelOrder(String idUser, String idOrder) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ທ່ານຕ້ອງການຈະຍົກເລີກ Order ແທ້ບໍ?'),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await notificationToUser(idUser);                
                  deleteOrder(idOrder);
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    )),
                icon: Icon(Icons.check),
                label: Text('ຢືນຢັນ'),
              ),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel),
                  label: Text('ຍົກເລີກ'))
            ],
          )
        ],
      ),
    );
  }

  Future<Null> deleteOrder(String idOrder) async {
    String url =
        '${MyConstant().domain}/chouayeefood/deleteOrderWhereId.php?isAdd=true&id=$idOrder';
    await Dio().get(url).then((value) {
      findIdShopAndReadOrder();
    });
  }

  Container buildTitle() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.lime.shade700),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'ລາຍການອາຫານ',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'ລາຄາ',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'ຈຳນວນ',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'ລວມ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> notificationToUser(String idUser) async {
    String urlFindToken =
        '${MyConstant().domain}/chouayeefood/getUserWhereId.php?isAdd=true&id=$idUser';
    await Dio().get(urlFindToken).then((value) {
      var resultUser = json.decode(value.data);
      print('resultUser ==>> $resultUser');
      for (var json in resultUser) {
        UserModel model = UserModel.fromJson(json);
        String tokenUser = model.token;
        print('tokenUser ===>> $tokenUser');

        String title = 'ຮ້ານຄ້າ ຍົກເລີກການ Order';
        String body = 'ຮ້ານຄ້າບໍ່ສະດວກຮັບ Order ໃນຕອນນີ້';
        String urlSendToken =
            '${MyConstant().domain}/chouayeefood/apiNotification.php?isAdd=true&token=$tokenUser&title=$title&body=$body';

        sendNotificationToUser(urlSendToken);
      }
    });
  }

  Future<Null> notificationToRider() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String nameShop = preferences.getString(MyConstant().keyName);

    String urlSelectToken =
        '${MyConstant().domain}/chouayeefood/getUserWhereId.php?isAdd=true&id=8';
    await Dio().get(urlSelectToken).then((value) {
      var result = json.decode(value.data);
      for (var map in result) {
        UserModel model = UserModel.fromJson(map);
        String tokenRider = model.token;
        String chooseType = model.chooseType;

        if(chooseType == 'Rider'){
          String title = 'ມີ Order ຈາກຮ້ານ $nameShop';
        String body = 'ມີການສັ່ງອາຫານຈາກລູກຄ້າ';
        String urlSendToKen =
            '${MyConstant().domain}/chouayeefood/apiNotification.php?isAdd=true&token=$tokenRider&title=$title&body=$body';
        sendNotificationToRider(urlSendToKen);
        }
        
      }
    });
  }

  Future<Null> sendNotificationToUser(String urlSendToken) async {
    await Dio()
        .get(urlSendToken)
        .then((value) => normalDialog(context, 'ຍົກເລີກ Order ໄປຫາລູກຄ້າແລ້ວ'));
  }

  Future<Null> sendNotificationToRider(String urlSendToKen) async {
    await Dio()
        .get(urlSendToKen)
        .then((value) => normalDialog(context, 'ສົ່ງ Order ໃຫ້ Rider ສຳເລັດ'));
  }

  Future<Null> updateOrderStatus(String idOrder) async {
    String url =
        '${MyConstant().domain}/chouayeefood/editStatusWhereOrderId.php?isAdd=true&Status=ShopCooking&id=$idOrder';
    await Dio().get(url).then((value) {
      Toast.show('ຮັບ Order ສຳເລັດ', context, duration: Toast.LENGTH_LONG);
    });
  }


}
