import 'package:chouayeefood/utility/my_constant.dart';
import 'package:chouayeefood/utility/my_style.dart';
import 'package:chouayeefood/utility/normal_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String chooseType, name, user, password, phone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: ListView(
        padding: EdgeInsets.all(30.0),
        children: <Widget>[
          myLogo(),
          MyStyle().mySizebox(),
          showAppName(),
          MyStyle().mySizebox(),
          nameForm(),
          MyStyle().mySizebox(),
          userForm(),
          MyStyle().mySizebox(),
          passwordForm(),
          MyStyle().mySizebox(),
          phoneForm(),
          MyStyle().mySizebox(),
          MyStyle().showTitleH2('ປະເພດຂອງສະມາຊິກ :'),
          MyStyle().mySizebox(),
          userRadio(),
          shopRadio(),
          riderRadio(),
          registerButton(),
        ],
      ),
    );
  }

  Widget registerButton() => Container(
        width: 250.0,
        child: ElevatedButton(
          //color: MyStyle().darkColor,
          style: ElevatedButton.styleFrom(primary: MyStyle().darkColor),
          onPressed: () {
            print(
                'name = $name, user = $user, password = $password, chooseType = $chooseType, phone =$phone');
            if (name == null ||
                name.isEmpty ||
                user == null ||
                user.isEmpty ||
                password == null ||
                password.isEmpty ||
                phone == null ||
                phone.isEmpty) {
              print('Have Space');
              normalDialog(context, 'ມີຊ່ອງວ່າງເດີ້ ກະລຸນາຕື່ມຂໍ້ມູນໃຫ້ຄົບ');
            } else if (chooseType == null) {
              normalDialog(context, 'ກະລຸນາເລືອກປະເພດຂອງຜູ້ສະມັກ');
            } else {
              checkUser();
            }
          },
          child: Text(
            'Register',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Future<Null> checkUser() async {
    String url =
        '${MyConstant().domain}/chouayeefood/getUserWhereUser.php?isAdd=true&User=$user';
    try {
      Response response = await Dio().get(url);
      if (response.toString() == 'null') {
        registerThread();
      } else {
        normalDialog(
            context, 'user ນີ້ $user ມີຄົນອື່ນໃຊ້ໄປແລ້ວ ກະລຸນາປ່ຽນ user ໃໝ່');
      }
    } catch (e) {}
  }

  Future<Null> registerThread() async {
    String url =
        '${MyConstant().domain}/chouayeefood/addUserAndPhone.php?isAdd=true&ChooseType=$chooseType&Name=$name&User=$user&Password=$password&Phone=$phone';
    try {
      Response response = await Dio().get(url);
      print('res = $response');

      if (response.toString() == 'true') {
        Navigator.pop(context);
      } else {
        normalDialog(context, 'ບໍສາມາດສະມັກໄດ້ ກະລຸນາລອງໃໝ່');
      }
    } catch (e) {}
  }

  Row userRadio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio(
          value: 'User',
          groupValue: chooseType,
          onChanged: (value) {
            setState(() {
              chooseType = value;
            });
          },
        ),
        Text(
          'ຜູ້ສັ່ງອາຫານ',
          style: TextStyle(color: MyStyle().darkColor),
        )
      ],
    );
  }

  Row riderRadio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio(
          value: 'Rider',
          groupValue: chooseType,
          onChanged: (value) {
            setState(() {
              chooseType = value;
            });
          },
        ),
        Text(
          'ຜູ້ສົ່ງອາຫານ',
          style: TextStyle(color: MyStyle().darkColor),
        )
      ],
    );
  }

  Row shopRadio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio(
          value: 'Shop',
          groupValue: chooseType,
          onChanged: (value) {
            setState(() {
              chooseType = value;
            });
          },
        ),
        Text(
          'ເຈົ້າຂອງຮ້ານ',
          style: TextStyle(color: MyStyle().darkColor),
        )
      ],
    );
  }

  Widget nameForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => name = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.face,
                  color: MyStyle().darkColor,
                ),
                labelStyle: TextStyle(color: MyStyle().darkColor),
                labelText: 'ຊື່ແທ້ :',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkColor)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().primaryColor)),
              ),
            ),
          ),
        ],
      );

  Widget userForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => user = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.account_box,
                  color: MyStyle().darkColor,
                ),
                labelStyle: TextStyle(color: MyStyle().darkColor),
                labelText: 'ຊື່ User :',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkColor)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().primaryColor)),
              ),
            ),
          ),
        ],
      );

  Widget passwordForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => password = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                  color: MyStyle().darkColor,
                ),
                labelStyle: TextStyle(color: MyStyle().darkColor),
                labelText: 'ລະຫັດຜ່ານ :',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkColor)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().primaryColor)),
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
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.phone,
                  color: MyStyle().darkColor,
                ),
                labelText: 'ເບີໂທ :',
                labelStyle: TextStyle(color: MyStyle().darkColor,),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyStyle().darkColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyStyle().primaryColor),
                )
              ),
            ),
          )
        ],
      );

  Row showAppName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyStyle().showTitle('Chouayee Food'),
      ],
    );
  }

  Widget myLogo() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyStyle().showLogo(),
        ],
      );
}
