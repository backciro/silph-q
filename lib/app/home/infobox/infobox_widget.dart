import 'package:SILPH_Q/app/app_module.dart';
import 'package:SILPH_Q/app/home/home_bloc.dart';
import 'package:SILPH_Q/app/home/infobox/radiorow_widget.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class InfoBoxWidget extends StatelessWidget {
  final HomeBloc _homeBloc = AppModule.to.getBloc();

  final Function triggerCapacityExceed;

  InfoBoxWidget({this.triggerCapacityExceed});

  String getActiveSpot(List<dynamic> data, String key) {
    final _data = data.where((w) => w['selected']);
    if (_data.length > 0) {
      return _data.first[key];
    } else
      return '0';
  }

  String getNowInside(List<dynamic> data) {
    final _data = data.where((w) => w['selected']);
    if (_data.length > 0) {
      return _data.first['currentInside'].toString() ?? '0';
    } else
      return '0';
  }

  bool isCapacityExceed(List<dynamic> data, context) {
    if (data != null && data.length > 0) {
      final _rawData = data.where((w) => w['selected']);
      final _data = _rawData.length > 0 ? _rawData.first : null;

      if (_data != null) {
        Future.delayed(Duration(seconds: 1), () {
          triggerCapacityExceed(
              int.parse(_data['currentInside'].toString()) + 1 >=
                  int.parse(_data['capacity'].toString()));
        });

        return int.parse(_data['currentInside'].toString()) >=
            int.parse(_data['capacity'].toString());
      } else
        return false;
    } else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _homeBloc.opModeState,
      initialData: _homeBloc.currentMode ?? 0,
      builder: (context, snapshot) => new Container(
        height: 250,
        padding: EdgeInsets.only(top: 10),
        child: StreamBuilder<Object>(
            stream: _homeBloc.placeListState,
            initialData: _homeBloc.placeList ?? new List(),
            builder: (context, innerSnapshot) {
              return Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        width: 100,
                        child: Text(
                          'Spot',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            getActiveSpot(innerSnapshot.data, 'nameidentity') ==
                                    '0'
                                ? 'Nessuno SPOT Selezionato'
                                : getActiveSpot(
                                    innerSnapshot.data, 'nameidentity'),
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: .5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        width: 140,
                        child: Text(
                          'Capienza',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        width: 150,
                        padding: const EdgeInsets.fromLTRB(32, 8, 28, 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        child: Transform.scale(
                          scale: isCapacityExceed(innerSnapshot.data, context)
                              ? 1.3
                              : 1,
                          child: Text(
                            '${getNowInside(innerSnapshot.data)} / ${getActiveSpot(innerSnapshot.data, 'capacity')}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 2,
                              color:
                                  isCapacityExceed(innerSnapshot.data, context)
                                      ? Colors.redAccent
                                      : Color(0xFF274156),
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
//                      Expanded(
//                        child:
//                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RadioRow(
                        selectedMode: snapshot.data,
                      )
                    ],
                  ),
                ],
              );
            }),
      ),
    );
  }
}
