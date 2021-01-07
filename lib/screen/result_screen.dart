import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pps/constant.dart';
import 'package:pps/model/room.dart';
import 'package:pps/model/candidate.dart';

class ResultScreen extends StatefulWidget {
  final Room room;

  ResultScreen({Key key, @required this.room}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState(room);
}

class _ResultScreenState extends State<ResultScreen> {
  _ResultScreenState(this.room);

  Room room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Hasil Suara",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Container(
          color: Colors.white,
          child: ListView(children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: 20.0, left: 20.0, bottom: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("${room.name}",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline6),
                  Text("Code: ${room.code}"),
                  Text("Deskripsi: ${room.description ?? ''}"),
                ],
              ),
            ),
            Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                countBoard(
                    label: "Suara Sah",
                    value: room.validVote,
                    color: Colors.blue),
                countBoard(
                  label: "Suara Tidak Sah",
                  value: room.invalidVote,
                  color: Colors.red,
                ),
                countBoard(
                    label: "Total Suara",
                    value: room.totalVote,
                    color: Colors.green)
              ],
            ),
            Divider(),
            Container(child: candidatesBuilder())
          ]),
        ));
  }

  Future<List<Candidate>> fetchCandidates() async {
    final response =
        await http.get('$API_ENDPOINT/api/rooms/${room.id}/candidates');

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((candidate) {
        return new Candidate.fromJson(candidate);
      }).toList();
    }
  }

  FutureBuilder<List<Candidate>> candidatesBuilder() {
    return FutureBuilder<List<Candidate>>(
        future: fetchCandidates(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Candidate> data = snapshot.data;
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                Candidate candidate = data[index];
                return Container(
                  padding: EdgeInsets.only(top: 20.0, left: 20, right: 20),
                  child: Card(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                            width: 120,
                            child: Image.network("${candidate.image}")),
                        Container(
                          padding: EdgeInsets.only(
                              top: 10, left: 20, right: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${candidate.name}",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                "Total Suara: ${candidate.totalVote} (${candidate.percentage}%)",
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return SizedBox(
                height: 300.0, child: Center(child: Text("${snapshot.error}")));
          }

          return SizedBox(
              height: 300.0, child: Center(child: CircularProgressIndicator()));
        });
  }

  Widget countBoard({String label, int value, Color color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.caption),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text("$value", style: Theme.of(context).textTheme.headline5),
          ),
          SizedBox(
            height: 10,
            width: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(color: color),
            ),
          )
        ],
      ),
    );
  }
}
