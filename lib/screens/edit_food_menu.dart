import 'dart:io';

import 'package:chouayeefood/model/food_model.dart';
import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditFoodMenu extends StatefulWidget {
  final FoodModel foodModel;
  EditFoodMenu({Key key, this.foodModel}) : super(key: key); // still have error

  @override
  _EditFoodMenuState createState() => _EditFoodMenuState();
}

class _EditFoodMenuState extends State<EditFoodMenu> {
  FoodModel foodModel;
  File file;
  String name, price, detail, pathImage;

  @override
  void initState() {
    super.initState();
    foodModel = widget.foodModel;
    name = foodModel.nameFood;
    price = foodModel.price;
    detail = foodModel.detail;
    pathImage = foodModel.pathImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: uploadButton(),
      appBar: AppBar(
        title: Text('ການແກ້ໄຂ ເມນູ ${foodModel.nameFood}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            nameFood(),
            groupImage(),
            priceFood(),
            detailFood(),
          ],
        ),
      ),
    );
  }

  FloatingActionButton uploadButton() {
    return FloatingActionButton(
      onPressed: () {
        if (name.isEmpty || price.isEmpty || detail.isEmpty) {
          normalDialog(context, 'ກະລຸນາຕື່ມຂໍ້ມູນໃຫ້ຄົບ');
        } else {
          confirmEdit();
        }
      },
      child: Icon(Icons.cloud_upload),
    );
  }

  Future<Null> confirmEdit() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ທ່ານຕ້ອງການແກ້ໄຂ ເມນູອາຫານ ແທ້ ຫຼື ບໍ ?'),
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  editValOnMySql();
                },
                icon: Icon(Icons.check,color: Colors.green,),
                label: Text('ແກ້ໄຂ'),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.clear,color: Colors.red,),
                label: Text('ຍົກເລີກ'),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<Null> editValOnMySql() async {

    String id = foodModel.id;
    String url = '${MyConstant().domain}/chouayeefood/editFoodWhereId.php?isAdd=true&id=$id&NameFood=$name&PathImage=$pathImage&Price=$price&Detail=$detail';
    await Dio().get(url).then((value){
      if (value.toString() == 'true') {
        Navigator.pop(context);
      } else {
        normalDialog(context, 'ແກ້ໄຂບໍໄດ້ ກະລຸນາລອງໃໝ່');
      }
    });

  }

  Widget groupImage() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: () => chooseImage(ImageSource.camera),
        ),
        Container(
          padding: EdgeInsets.all(16.0),
          width: 250.0,
          height: 250.0,
          child: file == null
              ? Image.network(
                  '${MyConstant().domain}${foodModel.pathImage}',
                  fit: BoxFit.cover,
                )
              : Image.file(file),
        ),
        IconButton(
          icon: Icon(Icons.add_photo_alternate),
          onPressed: () => chooseImage(ImageSource.gallery),
        ),
      ]);

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

  Widget detailFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 16.0),
                width: 250.0,
                child: TextFormField(
                  onChanged: (value) => detail = value.trim(),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  initialValue: detail,
                  decoration: InputDecoration(
                    labelText: 'ລາຍລະອຽດອາຫານ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget priceFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => price = value.trim(),
              keyboardType: TextInputType.number,
              initialValue: price,
              decoration: InputDecoration(
                labelText: 'ລາຄາອາຫານ',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );

  Widget nameFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => name = value.trim(),
              initialValue: name,
              decoration: InputDecoration(
                labelText: 'ຊື່ເມນູອາຫານ',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );
}
