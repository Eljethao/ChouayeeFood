import 'dart:io';
import 'dart:math';

import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFoodMenu extends StatefulWidget {
  @override
  _AddFoodMenuState createState() => _AddFoodMenuState();
}

class _AddFoodMenuState extends State<AddFoodMenu> {
  File file;
  String nameFood, price, detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ເພີ່ມລາຍການເມນູອາຫານ'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            showTitleFood('ຮູບອາຫານ'),
            groupImage(),
            showTitleFood('ລາຍລະອຽດອາຫານ'),
            nameForm(),
            MyStyle().mySizebox(),
            priceForm(),
            MyStyle().mySizebox(),
            detailForm(),
            MyStyle().mySizebox(),
            saveButton(),
          ],
        ),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.green[400],
        ),
        onPressed: () {
          if (file == null) {
            //check that we have chosen picture yet
            normalDialog(context, 'ກະລຸນາເລືອກຮູບພາບອາຫານກ່ອນ');
          } else if (nameFood == null ||
              nameFood.isEmpty ||
              price == null ||
              price.isEmpty ||
              detail == null ||
              detail.isEmpty) {
            normalDialog(context, 'ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບ');
          } else {
            uploadFoodandInsertData();
          }
        },
        icon: Icon(Icons.save),
        label: Text('Save food Menu'),
      ),
    );
  }

  Future<Null> uploadFoodandInsertData() async {
    String urlUpload = '${MyConstant().domain}/chouayeefood/saveFood.php?';

    Random random = Random();
    int i = random.nextInt(1000000);
    String nameFile = 'food$i.jpg';

    try {
      Map<String, dynamic> map = Map();
      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);

      await Dio().post(urlUpload, data: formData).then((value) async {
        String urlPathImage = '/chouayeefood/Food/$nameFile';
        print('urlPathImage = ${MyConstant().domain}$urlPathImage');

        SharedPreferences preferences = await SharedPreferences.getInstance();
        String idShop = preferences.getString('id');

        String urlInsertData =
            '${MyConstant().domain}/chouayeefood/addFood.php?isAdd=true&idShop=$idShop&NameFood=$nameFood&PathImage=$urlPathImage&Price=$price&Detail=$detail';
        await Dio().get(urlInsertData).then((value) => Navigator.pop(context));
      });
    } catch (e) {}
  }

  Widget nameForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => nameFood = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.fastfood),
            labelText: 'ຊື່ອາຫານ',
            border: OutlineInputBorder(),
          ),
        ),
      );

  Widget priceForm() => Container(
        width: 250.0,
        child: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) => price = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.attach_money),
            labelText: 'ລາຄາອາຫານ',
            border: OutlineInputBorder(),
          ),
        ),
      );

  Widget detailForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => detail = value.trim(),
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.details),
            labelText: 'ລາຍລະອຽດອາຫານ',
            border: OutlineInputBorder(),
          ),
        ),
      );

  Row groupImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: () => chooseImage(ImageSource.camera),
        ),
        Container(
          width: 250.0,
          height: 250.0,
          child: file == null
              ? Image.asset('images/spakaty.png')
              : Image.file(file),
        ),
        IconButton(
          icon: Icon(Icons.add_photo_alternate),
          onPressed: () => chooseImage(ImageSource.gallery),
        ),
      ],
    );
  }

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
    } catch (e) {}
  }

  Widget showTitleFood(String string) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: [
          MyStyle().showTitleH2(string),
        ],
      ),
    );
  }
}
