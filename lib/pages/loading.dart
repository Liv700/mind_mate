import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}



class _LoadingState extends State<Loading> {

  void goToHome() async {
    await Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      goToHome();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: Center(
        child: SpinKitCubeGrid(
          color: Colors.white,
          size: 90.0,
        ),
      ),
    );
  }
}
