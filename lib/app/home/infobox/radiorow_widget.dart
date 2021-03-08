import 'package:SILPH_Q/app/app_module.dart';
import 'package:SILPH_Q/app/home/home_bloc.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:custom_radio_button/custom_radio_button.dart';
import 'package:custom_radio_button/radio_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double PI = 3.1415926535897932;

class RadioRow extends StatelessWidget {
  RadioRow({Key key, this.selectedMode}) : super(key: key);

  final int selectedMode;
  final HomeBloc _homeBloc = AppModule.to.getBloc();
  final List<bool> isSelected = [false, false, false];
  final List<String> isSelectedText = ['INGRESSO', 'CONTROLLO', 'USCITA'];

  setSelectedMode(val) {
    _homeBloc.opModeEventSink.add(val);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: _homeBloc.opModeState,
      initialData: _homeBloc.currentMode ?? 0,
      builder: (context, snapshot) {
        isSelected[snapshot.data] = true;
        return Expanded(
          child: Center(
            child: Column(
              children: [
                ToggleButtons(
                  color: Color(0xFF274156),
                  focusColor: Color(0xFF1C6E8C),
                  selectedColor: Color(0xFF1C6E8C),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  children: <Widget>[
                    Container(
                      width: 75,
                      child: Icon(
                        Icons.transit_enterexit,
                        color: Color(0xFF1A8A5D),
                      ),
                    ),
                    Container(
                      width: 75,
                      child: Icon(
                        Icons.assignment,
                        color: Color(0xFFCCA03D),
                      ),
                    ),
                    Container(
                      width: 75,
                      child: Transform.rotate(
                        angle: PI,
                        child: Icon(
                          Icons.transit_enterexit,
                          color: Color(0xFFE53665),
                        ),
                      ),
                    ),
                  ],
                  onPressed: (int index) {
                    setSelectedMode(index);
                  },
                  isSelected: isSelected,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    isSelectedText[snapshot.data],
                    style: TextStyle(
                      fontSize: 15.0,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}