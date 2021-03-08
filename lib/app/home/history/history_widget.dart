import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryWidget extends StatefulWidget {
  final List<dynamic> historyTracks = new List();

  HistoryWidget();

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  SafeZoneHandler _safeZoneHandler = new SafeZoneHandler();
  List<dynamic> trackList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _retrieveData();
  }

  _retrieveData() async {
    trackList = await _safeZoneHandler.getTrackList();

    trackList.sort((a, b) {
      return DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp']));
    });
  }

  void showConfirmDialog(BuildContext context) {
    SimpleDialog fancyDialog = SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      title: Center(
          child: new Text(
        "Elimina Cronologia",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      )),
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: new Text(
              'Sei sicuro di voler eliminare la cronologia dei tuoi '
              'spostamenti dalla memoria locale?',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: new Text(
              'Quest\'operazione è irreversibile',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SimpleDialogOption(
              child: new Text(
                "Annulla",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SimpleDialogOption(
                child: new Text(
                  "Conferma",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteHistory();
                })
          ],
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => fancyDialog,
    );
  }

  _deleteHistory() async {
    _safeZoneHandler.setTrackList([]);
    for (var i = trackList.length - 1; i >= 0; i--) {
      await Future.delayed(Duration(milliseconds: 67));
      trackList.removeLast();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            child: Icon(Icons.keyboard_arrow_down),
          ),
        ),
        centerTitle: true,
        primary: true,
        title: Text(
          'I MIEI CHECK-IN',
          style: TextStyle(
            fontSize: 18.0,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD0CCD0),
          ),
        ),
        backgroundColor: Color(0xFF274156),
      ),
      body: (trackList != null && trackList.length > 0)
          ? Container(
              child: new Stack(
                children: <Widget>[
                  Positioned(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 45),
                      child: ListView.builder(
                        itemCount: trackList?.length,
                        itemBuilder: (context, i) {
                          return ListTile(
                            title: Text(trackList[i]['spotname'] ?? ''),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy  -  HH:mm').format(
                                DateTime.parse(trackList[i]['timestamp']),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: FlatButton.icon(
                      onPressed: () => showConfirmDialog(context),
                      icon: Icon(Icons.clear_all),
                      label: Text('Cancella Cronologia'),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              child: new Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    right: 0,
                    child: FlatButton.icon(
                      icon: Icon(Icons.clear_all),
                      label: Text('Cancella Cronologia'),
                      onPressed: () => showConfirmDialog(context),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
