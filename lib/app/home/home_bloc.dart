import 'package:bloc_pattern/bloc_pattern.dart';

class HomeBloc extends BlocBase {
  final String firstImage = "assets/veliero9.jpg";

  final String firstTitle = "CREMA & CHOCO";

  //dispose will be called automatically by closing its streams
  @override
  void dispose() {
    super.dispose();
  }
}
