import 'dart:convert';

import 'package:chouayeefood/model/order_model.dart';
import 'package:chouayeefood/model/user_model.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class RiderOrderDetail extends StatefulWidget {
  final OrderModel orderModel;
  RiderOrderDetail({Key key, this.orderModel}) : super(key: key);
  @override
  _RiderOrderDetailState createState() => _RiderOrderDetailState();
}

class _RiderOrderDetailState extends State<RiderOrderDetail> {
  OrderModel orderModel;
  double lat, lng, lat1, lng1;
  List<UserModel> userModels = [];
  List<UserModel> modelUsers = [];
  List<OrderModel> orderModels = [];
  List<List<String>> listMenuFoods = [];
  List<List<String>> listPrices = [];
  List<List<String>> listAmounts = [];
  List<List<String>> listSums = [];
  List<int> totalInt = [];
  int id;
  CameraPosition position, userPosition;
  int sumPay = 0;
  bool isVisible = false;
  String idRider;

  @override
  void initState() {
    super.initState();
    orderModel = widget.orderModel;

    readIdShop();
    readOrderList();
    readPhoneUser();
  }

  Future<Null> readOrderList() async {
    String orderId = orderModel.id;
    // print('orderID ==>> $orderId');
    if (orderId != null) {
      String urlFindOrder =
          '${MyConstant().domain}/chouayeefood/getOrderWhereIdOrder.php?isAdd=true&id=$orderId';

      Response response = await Dio().get(urlFindOrder);
      // print('response ==>> $response');
      if (response.toString() != 'null') {
        var result = json.decode(response.data);
        for (var map in result) {
          OrderModel model = OrderModel.fromJson(map);
          List<String> menuFoods = changeArray(model.nameFood);
          List<String> prices = changeArray(model.price);
          List<String> amounts = changeArray(model.amount);
          List<String> sums = changeArray(model.sum);

          int total = 0;
          for (var string in sums) {
            total = total + int.parse(string.trim());
          }

          setState(() {
            orderModels.add(model);
            listMenuFoods.add(menuFoods);
            listPrices.add(prices);
            listAmounts.add(amounts);
            listSums.add(sums);
            totalInt.add(total);
            sumPay = total + int.parse(orderModel.transport.toString());
          });
        }
      }
    }
  }

  List<String> changeArray(String string) {
    List<String> list = [];
    String myString = string.substring(1, string.length - 1);
    list = myString.split(',');
    int index = 0;
    for (var string in list) {
      list[index] = string.trim();
      index++;
    }
    return list;
  }

  Future<Null> readIdShop() async {
    id = int.parse(orderModel.idShop);
    // print('index ==>> $id');
    String url =
        '${MyConstant().domain}/chouayeefood/getLatLngWhereidShop.php?isAdd=true&id=$id';
    Response response = await Dio().get(url);
    // print('response ==>> $response');
    var result = json.decode(response.data);
    for (var map in result) {
      UserModel model = UserModel.fromJson(map);
      setState(() {
        userModels.add(model);
        findLatLng();
      });
    }
  }

  Future<Null> readPhoneUser() async {
    id = int.parse(orderModel.idUser);
    String url =
        '${MyConstant().domain}/chouayeefood/getPhoneWhereidUser.php?isAdd=true&id=$id';
    Response response = await Dio().get(url);
    var result = json.decode(response.data);
    for (var map in result) {
      UserModel model = UserModel.fromJson(map);
      setState(() {
        modelUsers.add(model);
        findUserLatLng();
      });
    }
  }

  Future<Null> findUserLatLng() async {
    lat1 = double.parse(modelUsers[0].lat);
    lng1 = double.parse(modelUsers[0].lng);
    print('lat1 => $lat1, lng1 => $lng1');
  }

  Future<Null> findLatLng() async {
    lat = double.parse(userModels[0].lat);
    lng = double.parse(userModels[0].lng);
    print('lat == $lat, lng == $lng');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: getOrderButton(),
      appBar: AppBar(
        title: Text('RiderOrderDetail Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            builtContent(),
            //builtMenu(),
            //buildListFood(),
          ],
        ),
      ),
    );
  }

  Container showMap() {
    if (lat != null) {
      LatLng latLng = LatLng(lat, lng);
      position = CameraPosition(
        target: latLng,
        zoom: 16.0,
      );
    }

    Marker shopMarker() {
      return Marker(
        markerId: MarkerId('shopMarker'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(60.0),
        infoWindow: InfoWindow(title: userModels[0].nameShop),
      );
    }

    Set<Marker> mySet() {
      return <Marker>[shopMarker()].toSet();
    }

    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      // color: Colors.grey,
      height: 250,
      child: lat == null
          ? MyStyle().showProgress()
          : GoogleMap(
              initialCameraPosition: position,
              mapType: MapType.normal,
              onMapCreated: (controller) {},
              markers: mySet(),
            ),
    );
  }

  Container showUserMap() {
    if (lat1 != null) {
      LatLng latLng1 = LatLng(lat1, lng1);
      userPosition = CameraPosition(
        target: latLng1,
        zoom: 16.0,
      );
    }

    Marker userMarker() {
      return Marker(
        markerId: MarkerId('userMarker'),
        position: LatLng(lat1, lng1),
        icon: BitmapDescriptor.defaultMarkerWithHue(150.0),
        infoWindow: InfoWindow(title: modelUsers[0].name),
      );
    }

    Set<Marker> userSet() {
      return <Marker>[userMarker()].toSet();
    }

    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      height: 250,
      child: lat1 == null
          ? MyStyle().showProgress()
          : GoogleMap(
              initialCameraPosition: userPosition,
              mapType: MapType.normal,
              onMapCreated: (controller) {},
              markers: userSet(),
            ),
    );
  }

  FloatingActionButton getOrderButton() {
    return FloatingActionButton(
      onPressed: () {
        confirmGetOrder();
      },
      child: Icon(Icons.motorcycle),
    );
  }

  Future<Null> confirmGetOrder() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ຢືນຢັນການຮັບ Order'),
          ],
        ),
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
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isVisible = true;
                    updateIdRider(orderModel.id);
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
                  ),
                ),
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

  Future<Null> updateIdRider(String idOrder) async {
    String status = "RiderHandle";
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idRider = preferences.getString(MyConstant().keyId);
    print('idRider ===>>> $idRider');

    String url =
        '${MyConstant().domain}/chouayeefood/editRiderIdAndStatusWhereIdOrder.php?isAdd=true&idRider=$idRider&Status=$status&id=$idOrder';
    await Dio().get(url).then((value){
      Toast.show('ຢືນຢັນສຳເລັດ', context, duration: Toast.LENGTH_LONG);

    }
        );
  }

  Widget shopName() => Row(
        children: [
          Container(
            child: MyStyle().showTitleH2(orderModel.nameShop),
          ),
        ],
      );

  Widget buildListFood(int index) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: listMenuFoods[index].length,
      itemBuilder: (context, index2) => Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(left: 8),
              child: Text(listMenuFoods[index][index2]),
            ),
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
            child: Text(listSums[index][index2]),
          ),
        ],
      ),
    );
  }

  Container builtTitle() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey),
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

  Widget builtContent() => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: orderModels.length,
        itemBuilder: (context, index) => Column(
          children: [
            shopName(),
            showMap(),
            MyStyle().mySizebox(),
            builtTitle(),
            buildListFood(index),
            Divider(),
            builtTotal(index),
            MyStyle().mySizebox(),
            userInformation(index),
            showUserMap(),
            sendToUserSuccess(),
          ],
        ),
      );

  Widget sendToUserSuccess() {
    return Visibility(
      visible: isVisible,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                updateStatusToFinish(orderModel.id);
              },
              icon: Icon(Icons.save),
              label: Text('ສົ່ງສຳເລັດ', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> updateStatusToFinish(String idOrder) async {
    String status = "Finish";
    String url =
        '${MyConstant().domain}/chouayeefood/editStatusWhereOrderId.php?isAdd=true&Status=$status&id=$idOrder';
    await Dio().get(url).then((value) =>
        Toast.show('ສົ່ງສຳເລັດແລ້ວ', context, duration: Toast.LENGTH_LONG));
  }

  Widget userInformation(int index) => Column(
        children: [
          Row(
            children: [
              MyStyle().showTitleH2('ຜູ້ສັ່ງອາຫານ  ' + orderModel.nameUser),
            ],
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Text(
                  'ເບີໂທ:  ',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              MyStyle().showTitleH3Purple(modelUsers[index].phone),
            ],
          )
        ],
      );

  Widget builtTotal(int index) => Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyStyle().showTitleH3Red('ລວມລາຄາອາຫານ: '),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: MyStyle().showTitleH3Purple(
                  totalInt[index].toString(),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyStyle().showTitleH3Red('ຄ່າສົ່ງ + ລາຄາອາຫານ: '),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: MyStyle().showTitleH3Purple(sumPay.toString()),
              ),
            ],
          )
        ],
      );
}
