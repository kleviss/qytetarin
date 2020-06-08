import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Tab4 extends StatefulWidget {
  @override
  _Tab4State createState() => _Tab4State();
}

class _Tab4State extends State<Tab4> {

  @override
  void initState() {
    super.initState();
    print('Tab4 instantiated');
  }
  @override
  Widget build(BuildContext context) {
    print('Tab4 built');
    return Scaffold(
//      appBar: AppBar(
//        title: const Text('App EXIT Test'),
//      ),
//      body: Center(
//        child: const Text('Shtyp buttonin e kuq per te dale nga appi!'),
//      ),
      body: dil(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
        label: Text('Mbyll aplikacionin'),
        tooltip: 'Mbylle pra',
        icon: new Icon(Icons.exit_to_app),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        focusColor: Colors.red,
        hoverColor: Colors.red,
        splashColor: Colors.red,
      ),
    );
  }

  Widget dil(){
    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("assets/images/splash.png"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}