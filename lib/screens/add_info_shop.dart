import 'dart:io';
import 'dart:math';

import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddInfoShop extends StatefulWidget {
  @override
  _AddInfoShopState createState() => _AddInfoShopState();
}

class _AddInfoShopState extends State<AddInfoShop> {
  //Field
  double lat, lng;
  File file;
  String nameShop, address, phone, urlImage;

  @override
  void initState() {
    super.initState();
    findLatLng();
  }

  Future<Null> findLatLng() async {
    LocationData locationData = await findLocationData();
    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;
    });
    print('lat = $lat, lng = $lng');
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Information Shop'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            MyStyle().mySizebox(),
            nameForm(),
            MyStyle().mySizebox(),
            addressForm(),
            MyStyle().mySizebox(),
            phoneForm(),
            MyStyle().mySizebox(),
            groupImage(),
            MyStyle().mySizebox(),
            lat == null ? MyStyle().showProgress() : showMap(),
            MyStyle().mySizebox(),
            saveButton()
          ],
        ),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(primary: MyStyle().primaryColor),
        onPressed: () {
          if (nameShop == null ||
              nameShop.isEmpty ||
              address == null ||
              address.isEmpty ||
              phone == null ||
              phone.isEmpty) {
            normalDialog(context, 'ກະລຸນາຕື່ມຂໍ້ມູນໃຫ້ຄົບ');
          } else if (file == null) {
            normalDialog(context, 'ກະລຸນາເລືອກຮູບພາບກ່ອນ');
          } else {
            uploadImage();
          }
        },
        icon: Icon(
          Icons.save,
        ),
        label: Text('Save Information'),
      ),
    );
  }

  Future<Null> uploadImage() async {
    Random random = Random();
    int i = random.nextInt(1000000);
    String nameImage = 'shop$i.jpg';

    String url = '${MyConstant().domain}/chouayeefood/saveShop.php';

    try {
      Map<String, dynamic> map = Map();
      map['file'] =
          await MultipartFile.fromFile(file.path, filename: nameImage);

      FormData formData = FormData.fromMap(map);
      await Dio().post(url, data: formData).then((value) {
        print('Response ==>> $value');
        urlImage = '/chouayeefood/Shop/$nameImage';
        print('urlImage = $urlImage');
        editUserShop();
      });
    } catch (e) {}
  }

  Future<Null> editUserShop() async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');

    String url = '${MyConstant().domain}/chouayeefood/editUserWhereId.php?isAdd=true&id=$id&NameShop=$nameShop&Address=$address&Phone=$phone&UrlPicture=$urlImage&Lat=$lat&Lng=$lng';

    await Dio().get(url).then((value) {
      if (value.toString() == 'true') {
        Navigator.pop(context);
      } else {
        normalDialog(context, 'ບໍ່ສາມາດບັນທຶກໄດ້ ກະລຸນາລອງໃໝ່');
      }
    });
  }

  Set<Marker> myMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('myShop'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: 'ຮ້ານຂອງທ່ານ',
          snippet: 'lat = $lat, lng = $lng',
        ),
      )
    ].toSet();
  }

  Container showMap() {
    LatLng latLng = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 16.0,
    );

    return Container(
      height: 300.0,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: myMarker(),
      ),
    );
  }

  Row groupImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
            icon: Icon(
              Icons.add_a_photo,
              size: 36.0,
            ),
            onPressed: () => chooseImage(ImageSource.camera)),
        Container(
          width: 250.0,
          child: file == null
              ? Image.asset('images/myImage.png')
              : Image.file(file),
        ),
        IconButton(
          icon: Icon(
            Icons.add_photo_alternate,
            size: 36.0,
          ),
          onPressed: () => chooseImage(ImageSource.gallery),
        )
      ],
    );
  }

  Future<Null> chooseImage(ImageSource imageSource) async {
    try {
      var object = await ImagePicker.pickImage(
        source: imageSource,
        maxHeight: 800.0,
        maxWidth: 800.0,
      );
      /*var object = await ImagePicker().getImage(
        source: imageSource,
        maxHeight: 800.0,
        maxWidth: 800.0,
      );*/
      setState(() {
        file = object;
      });
    } catch (e) {}
  }

  Widget nameForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => nameShop = value.trim(),
              decoration: InputDecoration(
                labelText: 'ຊື່ຮ້ານຄ້າ :',
                prefixIcon: Icon(Icons.account_box),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );

  Widget addressForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => address = value.trim(),
              decoration: InputDecoration(
                labelText: 'ທີ່ຢູ່ຮ້ານຄ້າ :',
                prefixIcon: Icon(Icons.place),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );

  Widget phoneForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => phone = value.trim(),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'ເບີຕິດຕໍ່ຮ້ານຄ້າ :',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );
}
