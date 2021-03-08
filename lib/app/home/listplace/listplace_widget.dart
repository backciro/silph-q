import 'package:SILPH_Q/app/app_module.dart';
import 'package:SILPH_Q/app/home/home_bloc.dart';
import 'package:SILPH_Q/app/services/socket-layer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListPlace extends StatelessWidget {
  final HomeBloc _homeBloc = AppModule.to.getBloc();
  final Function emit;

  ListPlace({this.emit});

  tapClick(i) {
    _homeBloc.tapClick(i);
    emit(i);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 40,
          child: Center(
            child: Text(
              'SPOT Disponibili',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          height: (MediaQuery.of(context).size.height / 3) - 40,
          width: MediaQuery.of(context).size.width - 50,
          child: StreamBuilder<List<dynamic>>(
            stream: _homeBloc.placeListState,
            initialData: _homeBloc.placeList,
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () => tapClick(i),
                    child: ListTile(
                      title: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: .1,
                            color: const Color(0xFF605856),
                          ),
                          color: snapshot.data[i]['selected']
                              ? Colors.black12
                              : Colors.transparent,
                          borderRadius: BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * .6,
                              child: Text(
                                snapshot.data[i]['nameidentity'],
                              ),
                            ),
                            snapshot.data[i]['selected']
                                ? Container(
                                    width: 10,
                                    child: Transform.scale(
                                      scale: 1.4,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF30956D),
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
