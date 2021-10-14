import 'dart:convert';

import 'package:chouayeefood/model/cart_model.dart';
import 'package:chouayeefood/model/user_model.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:chouayeefood/utility/sqlite_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ShowCart extends StatefulWidget {
  @override
  _ShowCartState createState() => _ShowCartState();
}

class _ShowCartState extends State<ShowCart> {
  List<CartModel> cartModels = [];
  int total = 0;
  bool status = true;
  double lat, lng;

  @override
  void initState() {
    super.initState();
    readSQLite();
    findLatLng();
  }

  Future<Null> findLatLng() async{
    LocationData locationData = await findLocationData();
    lat = locationData.latitude;
    lng = locationData.longitude;
    print('lat == $lat, lng == $lng');
  }

  Future<LocationData> findLocationData() async{
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  Future<Null> readSQLite() async {
    var object = await SQLiteHelper().readAllDataFromSQLite();
    print('object length ==> ${object.length}');
    if (object.length != 0) {
      for (var model in object) {
        String sumString = model.sum;
        int sumInt = int.parse(sumString);
        setState(() {
          status = false;
          cartModels = object;
          total += sumInt;
        });
      }
    } else {
      setState(() {
        status = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ກະຕ່າຂອງທ່ານ'),
      ),
      body: status
          ? Center(
              child: Text('ກະຕ່າວ່າງເປົ່າ'),
            )
          : buildContent(),
    );
  }

  Widget buildContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildNameShop(),
            buildHeadTitle(),
            buildListFood(),
            Divider(),
            buildTotal(),
            buildClearCartButton(),
            buildOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget buildClearCartButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              primary: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              )),
          onPressed: () {
            confirmDeleteAllData();
          },
          icon: Icon(Icons.delete_outline),
          label: Text('Clear ກະຕ່າ'),
        ),
      ],
    );
  }

  Widget buildOrderButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 130,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                primary: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                )),
            onPressed: () {
              updateUserLatLng();
              orderThread();
              
            },
            icon: Icon(Icons.fastfood),
            label: Text('ສັ່ງຊື້'),
          ),
        ),
      ],
    );
  }

  Future<Null> updateUserLatLng() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString(MyConstant().keyId);
    // print('idUser ==>> $id');
    String url = '${MyConstant().domain}/chouayeefood/editUserLatLngWhereIdUser.php?isAdd=true&Lat=$lat&Lng=$lng&id=$id';
    await Dio().get(url);
  }

  Widget buildTotal() => Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyStyle().showTitleH2('ລວມທັງໝົດ : '),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3Red(total.toString()),
          ),
        ],
      );

  Widget buildNameShop() {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              MyStyle().showTitleH2('ຮ້ານ ${cartModels[0].nameShop}'),
            ],
          ),
          Row(
            children: [
              MyStyle()
                  .showTitleH3('ໄລຍະທາງ = ${cartModels[0].distance} ກິໂລແມັດ'),
            ],
          ),
          Row(
            children: [
              MyStyle()
                  .showTitleH3('ຄ່າຂົນສົ່ງ = ${cartModels[0].transport} ກີບ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHeadTitle() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: MyStyle().showTitleH3('ລາຍການອາຫານ'),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3('ລາຄາ'),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3('ຈຳນວນ'),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3('ລວມ'),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().mySizebox(),
          )
        ],
      ),
    );
  }

  Widget buildListFood() => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: cartModels.length,
        itemBuilder: (context, index) => Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(cartModels[index].nameFood),
            ),
            Expanded(
              flex: 1,
              child: Text(cartModels[index].price),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cartModels[index].amount),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(cartModels[index].sum.toString()),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(
                  Icons.delete_forever,
                  size: 20,
                ),
                onPressed: () async {
                  int id = cartModels[index].id;
                  print('You Click Delete id = $id');
                  await SQLiteHelper()
                      .deleteDataWhereId(id)
                      .then((value) async {
                    print('Success Delete id = $id');
                    //readSQLite();

                    //test
                    var object = await SQLiteHelper().readAllDataFromSQLite();
                    print('object length ==> ${object.length}');
                    if (object.length != 0) {
                      //for (var model in object) {
                      String sumString = cartModels[index].sum;
                      int sumInt = int.parse(sumString);
                      setState(() {
                        status = false;
                        cartModels = object;
                        total = total - sumInt;
                      });
                      // }
                    } else {
                      setState(() {
                        status = true;
                      });
                    }
                    //test
                  });
                },
              ),
            ),
          ],
        ),
      );

  Future<Null> confirmDeleteAllData() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ທ່ານຕ້ອງການຈະລຶບລາຍການອາຫານທັງໝົດແທ້ບໍ ?'),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    )),
                onPressed: () async {
                  Navigator.pop(context);
                  await SQLiteHelper().deleteAllData().then((value) {
                    readSQLite();
                  });
                },
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
                label: Text('ຍົກເລີກ'),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<Null> orderThread() async {
    DateTime dateTime = DateTime.now();
    // print(dateTime.toString());
    String orderDateTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

    String idShop = cartModels[0].idShop;
    String nameShop = cartModels[0].nameShop;
    String distance = cartModels[0].distance;
    String transport = cartModels[0].transport;

    List<String> idFoods = [];
    List<String> nameFoods = [];
    List<String> prices = [];
    List<String> amounts = [];
    List<String> sums = [];

    for (var model in cartModels) {
      idFoods.add(model.idFood);
      nameFoods.add(model.nameFood);
      prices.add(model.price);
      amounts.add(model.amount);
      sums.add(model.sum);
    }

    String idFood = idFoods.toString();
    String nameFood = nameFoods.toString();
    String price = prices.toString();
    String amount = amounts.toString();
    String sum = sums.toString();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');
    String nameUser = preferences.getString('Name');

    print(
        'orderDateTime = $orderDateTime, idUser = $idUser, NameUser = $nameUser, idShop = $idShop, nameShop = $nameShop, distance = $distance, transport = $transport,');
    print(
        'idFood = $idFood, nameFood = $nameFood, price = $price, amount = $amount, sum = $sum');

    String url =
        '${MyConstant().domain}/chouayeefood/addOrder.php?isAdd=true&OrderDateTime=$orderDateTime&idUser=$idUser&NameUser=$nameUser&idShop=$idShop&nameShop=$nameShop&Distance=$distance&Transport=$transport&idFood=$idFood&NameFood=$nameFood&Price=$price&Amount=$amount&Sum=$sum&idRider=none&Status=UserOrder';

    //insert data to mysql
    await Dio().get(url).then((value) {
      if (value.toString() == 'true') {
        clearAllSQLite();
        notificationToShop(idShop);
      } else {
        normalDialog(context, 'ບໍ່ສາມາດ ສັ່ງຊື້ໄດ້ ກະລຸນາລອງໃໝ່');
      }
    });
  }

  Future<Null> clearAllSQLite() async {
    Toast.show(
      'ສັ່ງຊື້ສຳເລັດ',
      context,
      duration: Toast.LENGTH_LONG,
    );
    await SQLiteHelper().deleteAllData().then((value) {
      readSQLite();
    });
  }

  Future<Null> notificationToShop(String idShop) async {
    String urlFindToken =
        '${MyConstant().domain}/chouayeefood/getUserWhereId.php?isAdd=true&id=$idShop';
    await Dio().get(urlFindToken).then((value) {
      var result = json.decode(value.data);
      print('result ==>> $result');
      for (var json in result) {
        UserModel model = UserModel.fromJson(json);
        String tokenShop = model.token;
        print('tokenShop ==>> $tokenShop');

        String title = 'ມີ Order ຈາກລູກຄ້າ';
        String body = 'ມີການສັ່ງອາຫານຈາກລູກຄ້າ';
        String urlSendToken =
            '${MyConstant().domain}/chouayeefood/apiNotification.php?isAdd=true&token=$tokenShop&title=$title&body=$body';

        sendNotificationToShop(urlSendToken);
      }
    });
  }

  Future<Null> sendNotificationToShop(String urlSendToken) async {
    await Dio().get(urlSendToken).then(
          (value) => normalDialog(context, 'ສົ່ງ Order ໄປທີ່ຮ້ານຄ້າແລ້ວ'),
        );
  }
}
