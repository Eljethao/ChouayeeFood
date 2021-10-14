import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chouayeefood/model/user_model.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInfoShop extends StatefulWidget {
  @override
  _EditInfoShopState createState() => _EditInfoShopState();
}

class _EditInfoShopState extends State<EditInfoShop> {
  UserModel userModel;
  String nameShop, address, phone, urlPicture;
  Location location = Location();
  double lat, lng;
  File file;

  @override
  void initState() {
    super.initState();
    readCurrentInfo();

    location.onLocationChanged.listen((event) {
      setState(() {
        lat = event.latitude;
        lng = event.longitude;
        // print('lat = $lat, lng = $lng');
      });
    });
  }

  Future<Null> readCurrentInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');
    print('idShop ==> $idShop');

    String url =
        '${MyConstant().domain}/chouayeefood/getUserWhereId.php?isAdd=true&id=$idShop';

    Response response = await Dio().get(url);
    print('response ==>> $response');

    var result = json.decode(response.data);
    print('result ==>> $result');

    for (var map in result) {
      print('map ==>> $map');
      setState(() {
        userModel = UserModel.fromJson(map);
        nameShop = userModel.nameShop;
        address = userModel.address;
        phone = userModel.phone;
        urlPicture = userModel.urlPicture;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userModel == null ? MyStyle().showProgress() : showContent(),
      appBar: AppBar(
        title: Text('ແກ້ໄຂລາຍລະອຽດຮ້ານ'),
      ),
    );
  }

  Widget showContent() => SingleChildScrollView(
        child: Column(
          children: <Widget>[
            nameShopForm(),
            showImage(),
            addressForm(),
            MyStyle().mySizebox(),
            phoneForm(),
            lat == null ? MyStyle().showProgress() : showMap(),
            editButton()
          ],
        ),
      );

  Widget editButton() => Container(
        width: MediaQuery.of(context).size.width, //full screen in row
        child: ElevatedButton.icon(
          onPressed: () => confirmDialog(),
          icon: Icon(Icons.edit),
          label: Text('ປັບປຸງ ລາຍລະອຽດ'),
        ),
      );

  Future<Null> confirmDialog() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ຕ້ອງການແກ້ໄຂ ລາຍລະອຽດແທ້ບໍ?'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // OutlineButton(
              //   onPressed: null,
              //   child: Text('ຕ້ອງການ'),
              // ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green[400]),
                onPressed: () {
                  print('OK');
                  Navigator.pop(context);
                  editThread();
                },
                child: Text('ຕ້ອງການ'),
              ),
              // OutlineButton(
              //   onPressed: () => Navigator.pop(context),
              //   child: Text('ບໍ່ຕ້ອງການ'),
              // )
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red[400]),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ບໍ່ຕ້ອງການ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<Null> editThread() async {
    Random random = Random();
    int i = random.nextInt(100000);
    String nameFile = 'editShop$i.jpg';
    
    Map<String, dynamic> map = Map();
    map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile); // this is the problem
    FormData formData = FormData.fromMap(map);

    String urlUpload = '${MyConstant().domain}/chouayeefood/saveShop.php?';
    await Dio().post(urlUpload, data: formData).then((value) async {
      urlPicture = '/chouayeefood/Shop/$nameFile';
      //normalDialog(context, '$urlPicture');

      String id = userModel.id;
      // print('id = $id');

      String url ='${MyConstant().domain}/chouayeefood/editUserWhereId.php?isAdd=true&id=$id&NameShop=$nameShop&Address=$address&Phone=$phone&UrlPicture=$urlPicture&Lat=$lat&Lng=$lng';

      Response response = await Dio().get(url);
      if (response.toString() == 'true') {
        Navigator.pop(context);
      } else {
        normalDialog(context, 'ອັບເດດບໍໄດ້ ກະລຸນາລອງໃໝ່');
      }
    });
  }

  Set<Marker> currentMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('myMarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
            title: 'ຮ້ານຢູ່ບ່ອນນີ້', snippet: 'Lat = $lat, Lng = $lng'),
      )
    ].toSet();
  }

  Container showMap() {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 16.0,
    );

    return Container(
      margin: EdgeInsets.only(top: 16.0),
      height: 250,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: currentMarker(),
      ),
    );
  }

  Widget showImage() => Container(
        margin: EdgeInsetsDirectional.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () => chooseImage(ImageSource.camera),
            ),
            Container(
              width: 250.0,
              height: 200.0,
              child: file == null
                  ? Image.network('${MyConstant().domain}$urlPicture')
                  : Image.file(file),
            ),
            IconButton(
              icon: Icon(Icons.add_photo_alternate),
              onPressed: () => chooseImage(ImageSource.gallery),
            ),
          ],
        ),
      );

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var object = await ImagePicker().getImage(
        source: source,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );

      setState(() {
        file = File(object.path);
      });

      // var object = await ImagePicker.pickImage(
      //   source: source,
      //   maxWidth: 800.0,
      //   maxHeight: 800.0,
      // );
    } catch (e) {}
  }

  Widget nameShopForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => nameShop = value,
              initialValue: nameShop,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ຊື່ຂອງຮ້ານ',
              ),
            ),
          ),
        ],
      );

  Widget addressForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              onChanged: (value) => address = value,
              initialValue: address,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ທີ່ຢູ່ຂອງຮ້ານ',
              ),
            ),
          ),
        ],
      );

  Widget phoneForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => phone = value,
              initialValue: phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ເບີຕິດຕໍ່ຮ້ານ',
              ),
            ),
          ),
        ],
      );
}
