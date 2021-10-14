import 'dart:convert';

import 'package:chouayeefood/model/user_model.dart';
import 'package:chouayeefood/screens/add_info_shop.dart';
import 'package:chouayeefood/screens/edit_info_shop.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformationShop extends StatefulWidget {
  @override
  _InformationShopState createState() => _InformationShopState();
}

class _InformationShopState extends State<InformationShop> {
  UserModel userModel;

  @override
  void initState() {
    super.initState();
    readDataUser();
  }

  Future<Null> readDataUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');

    String url =
        '${MyConstant().domain}/chouayeefood/getUserWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      //print('value = $value');
      var result = json.decode(value.data);
      //print('result = $result');
      for (var map in result) {
        setState(() {
          userModel = UserModel.fromJson(map);
        });
        print('nameShop = ${userModel.nameShop}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        userModel == null
            ? MyStyle().showProgress()
            : userModel.nameShop.isEmpty
                ? showNoData(context)
                : showListinfoShop(),
        addAnEditButton(),
      ],
    );
  }

  Widget showListinfoShop() => Column(
        children: <Widget>[
          MyStyle().showTitleH2('ລາຍລະອຽດຮ້ານ ${userModel.nameShop}'),
          showImage(),
          Row(
            children: <Widget>[
              MyStyle().showTitleH2('ທີ່ຢູ່ຂອງຮ້ານ'),
            ],
          ),
          Row(
            children: <Widget>[
              Text(userModel.address),
            ],
          ),
          //MyStyle().mySizebox(),
          Row(
            children: [
              MyStyle().showTitleH3('ເບີໂທຕິດຕໍ່ຮ້ານ: '),
              Text(userModel.phone),
            ],
          ),
          // Row(children: [
          //   Text(userModel.phone),
          // ],),
          MyStyle().mySizebox(),
          showMap(),
        ],
      );

  Container showImage() {
    return Container(
      height: 150.0,
      width: 150.0,
      child: Image.network('${MyConstant().domain}${userModel.urlPicture}'),
    );
  }

  Set<Marker> shopMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('shopID'),
          position: LatLng(
            double.parse(userModel.lat),
            double.parse(userModel.lng),
          ),
          infoWindow: InfoWindow(
            title: "ຕຳແໜ່ງຂອງຮ້ານ",
            snippet:
                'Latitude =${userModel.lat}, Longtitude = ${userModel.lng}',
          ))
    ].toSet();
  }

  Widget showMap() {
    double lat = double.parse(userModel.lat);
    double lng = double.parse(userModel.lng);

    LatLng latLng = LatLng(lat, lng);
    CameraPosition position = CameraPosition(target: latLng, zoom: 16.0);

    return Expanded(
      child: GoogleMap(
        initialCameraPosition: position,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: shopMarker(),
      ),
    );
  }

  Widget showNoData(BuildContext context) =>
      MyStyle().titleCenter(context, 'ຍັງບໍ່ມີຂໍ້ມູນ ກະລຸນາເພີ່ມຂໍ້ມູນກ່ອນ');

  Row addAnEditButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.only(
                right: 16.0,
                bottom: 16.0,
              ),
              child: FloatingActionButton(
                child: Icon(Icons.edit),
                onPressed: () => routeToAddInfo(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void routeToAddInfo() {
    Widget widget = userModel.nameShop.isEmpty ? AddInfoShop() : EditInfoShop();
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => widget,
    );
    Navigator.push(context, materialPageRoute).then((value) => readDataUser());
  }
}
