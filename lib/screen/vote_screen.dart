import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pps/constant.dart';
import 'package:pps/model/room.dart';
import 'package:pps/model/candidate.dart';
import 'package:pps/model/vote.dart';
import 'package:pps/screen/result_screen.dart';

class VoteScreen extends StatefulWidget {
  final Room room;

  VoteScreen({Key key, @required this.room}) : super(key: key);

  @override
  _VoteScreenState createState() => _VoteScreenState(room);
}

class _VoteScreenState extends State<VoteScreen> {
  _VoteScreenState(this.room);

  Room room;
  List<Vote> votes;

  bool isLoadingEndVote = false;
  bool isLoadingBeginVote = false;
  bool isVoting = false;

  int validVote = 0;
  int invalidVote = 0;
  int totalVote = 0;

  @override
  Widget build(BuildContext context) {
    Widget voteChild;

    if (isVoting) {
      Widget endVoteButton = isLoadingEndVote
          ? Center(child: CircularProgressIndicator())
          : ElevatedButton.icon(
              icon: Icon(Icons.how_to_vote_outlined),
              label: Text("Selesai"),
              onPressed: () => endVote());

      voteChild = Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  countBoard(
                      label: "Suara Sah", value: validVote, color: Colors.blue),
                  countBoard(
                    label: "Suara Tidak Sah*",
                    value: invalidVote,
                    color: Colors.red,
                    onTap: () => _incInvalidVoteState(),
                  ),
                  countBoard(
                      label: "Total Suara",
                      value: totalVote,
                      color: Colors.green)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
              child: Text(
                  "*Klik label tidak sah untuk surat suara yang tercatat tidak sah.",
                  style: Theme.of(context).textTheme.caption),
            ),
            Container(
              child: endVoteButton,
            )
          ],
        ),
      );
    } else {
      Widget beginVoteButton = isLoadingBeginVote
          ? Center(child: CircularProgressIndicator())
          : ElevatedButton.icon(
              icon: Icon(Icons.how_to_vote_outlined),
              label: Text("Mulai Voting"),
              onPressed: () => beginVote());

      voteChild = Container(
        margin: EdgeInsets.only(top: 30, bottom: 40),
        child: Column(
          children: <Widget>[
            Container(
              child: beginVoteButton,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Klik untuk mulai melakukan perhitungan suara.",
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
      );
    }

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            title: Text(
              "Room",
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: Container(
              color: Colors.white,
              child: ListView(
                children: <Widget>[
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
                  Container(child: candidatesBuilder()),
                  Divider(),
                  Container(child: voteChild),
                ],
              )),
        ));
  }

  Future<bool> _onWillPop({bool isCloseDialog: false}) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Keluar Room?'),
            content: new Text(
                'Apakah anda ingin keluar dari room ini? jika anda tidak meng-klik tombol selesai, data tidak tersimpan ke sistem!'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('TIDAK'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  if (isCloseDialog) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: new Text('YA'),
              ),
            ],
          ),
        )) ??
        false;
  }

  // ignore: missing_return
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
            return Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: GridView.builder(
                  controller: null,
                  itemCount: data.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    Candidate candidate = data[index];
                    return gridviewItem(candidate);
                  },
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
                height: 300.0, child: Center(child: Text("${snapshot.error}")));
          }

          return SizedBox(
              height: 300.0, child: Center(child: CircularProgressIndicator()));
        });
  }

  Widget gridviewItem(Candidate candidate) {
    Widget counterLabel;
    int candidateId = candidate.id;

    if (isVoting) {
      int totalVote = 0;

      if (votes != null) {
        totalVote =
            votes.firstWhere((vote) => vote.candidateId == candidateId).total;
      }

      counterLabel = Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Text("$totalVote", style: Theme.of(context).textTheme.headline6),
        ],
      );
    }

    double imageHeight;
    MediaQueryData queryData;

    queryData = MediaQuery.of(context);
    imageHeight = queryData.size.height / 6;

    return Column(
      children: <Widget>[
        SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ]),
          child: Stack(children: [
            Ink(
              child: InkWell(
                onTap: () {
                  final _vote =
                      votes.firstWhere((el) => el.candidateId == candidateId);

                  setState(() {
                    _vote.total = _vote.total + 1;
                  });

                  _incValidVoteState();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: Image.network(
                    "${candidate.image}",
                    height: imageHeight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 5,
              left: 10,
              child: Container(
                  decoration:
                      BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text("${candidate.order}",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20.0))),
                  )),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: <Widget>[
              Text(
                "${candidate.name}",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Container(
                child: counterLabel,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget countBoard({String label, int value, Color color, onTap}) {
    return FlatButton(
      onPressed: onTap,
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

  void beginVote() async {
    setState(() {
      isLoadingBeginVote = true;
    });

    final response =
        await http.get('$API_ENDPOINT/api/rooms/${room.id}/candidates');

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);

      var _votes = jsonResponse.map((candidate) {
        Candidate _candidate = Candidate.fromJson(candidate);
        return new Vote(room.id, _candidate.id, 0);
      }).toList();

      setState(() {
        isLoadingBeginVote = false;
        isVoting = true;
        votes = _votes;
      });
    } else {
      setState(() {
        isLoadingBeginVote = false;
      });
    }
  }

  void endVote() async {
    setState(() {
      isLoadingEndVote = true;
    });

    final _votes = votes;
    _votes.add(Vote(room.id, null, invalidVote));
    final jsonInput = jsonEncode(_votes);

    final response = await http.post('$API_ENDPOINT/api/votes/${room.code}',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonInput);

    if (response.statusCode == 200) {
      room.validVote = validVote;
      room.invalidVote = invalidVote;
      room.totalVote = totalVote;

      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ResultScreen(room: room)));
    } else {
      setState(() {
        isLoadingEndVote = false;
      });
    }
  }

  void _incValidVoteState() {
    setState(() {
      validVote = validVote + 1;
      totalVote = totalVote + 1;
    });
  }

  void _incInvalidVoteState() {
    setState(() {
      invalidVote = invalidVote + 1;
      totalVote = totalVote + 1;
    });
  }
}
