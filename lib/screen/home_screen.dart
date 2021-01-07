import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pps/constant.dart';
import 'package:pps/screen/vote_screen.dart';
import 'package:pps/model/room.dart';
import 'package:pps/screen/result_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final textCodeController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/join.png',
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                'Aplikasi Proses Perhitungan Surat Suara',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Join ke room menggunakan kode untuk dapat mengakses dan melakukan perhitungan surat suara.',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModal(),
        child: Center(
          child: Icon(Icons.login_outlined),
        ),
      ),
    );
  }

  void showModal() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return isLoading
                ? SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()))
                : Padding(
                    padding: EdgeInsets.only(
                        top: 20,
                        left: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text("Masukan Kode",
                                style: Theme.of(context).textTheme.headline6)),
                        Text(
                          "Untuk melakukan perhitungan suara anda harus memasukkan kode yang sesuai dengan pemilihan ditempat anda.",
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: TextField(
                            controller: textCodeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                                hintText: "Contoh: GHDGXH",
                                labelText: "Kode",
                                suffix: InkWell(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                  ),
                                  onTap: () {
                                    textCodeController.text = "";
                                  },
                                )),
                          ),
                        ),
                        ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                              });

                              joinRoom().whenComplete(() {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                            icon: Icon(Icons.login_outlined),
                            label: Text("Join Room")),
                        SizedBox(
                          height: 10.0,
                        )
                      ],
                    ),
                  );
          });
        });
  }

  Future joinRoom() async {
    final response = await http
        .get('$API_ENDPOINT/api/rooms/${textCodeController.text}/join');

    if (response.statusCode == 200) {
      Map roomMap = jsonDecode(response.body);
      var room = Room.fromJson(roomMap);

      if (room.status == "OPEN") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VoteScreen(
                      room: room,
                    )));
      } else if (room.status == "CLOSE") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResultScreen(
                      room: room,
                    )));
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text("Tidak dapat menemukan room"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(
                          'Pastikan kode yang anda masukkan terdaftar dan aktif.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          });
    }
  }
}
