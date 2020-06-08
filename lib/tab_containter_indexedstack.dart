import 'package:flutter/material.dart';

import 'screens/tab1.dart';
import 'screens/tab2.dart';
import 'screens/tab3.dart';
import 'screens/tab4.dart';


class TabContainerIndexedStack extends StatefulWidget {
  TabContainerIndexedStack({Key key}) : super(key: key);

  @override
  _TabContainerIndexedStackState createState() =>
      _TabContainerIndexedStackState();
}

class _TabContainerIndexedStackState extends State<TabContainerIndexedStack> {
  int tabIndex = 0;
  List<Widget> listScreens;
  @override
  void initState() {
    super.initState();
    listScreens = [
      Tab2(),
      Tab1(),
      Tab3(),
      Tab4()
    ];
  }

  @override
  bool get wantKeepAlive => true; //by default it will be null, change it to true.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      home: SafeArea(
        child: Scaffold(
          body: IndexedStack(index: tabIndex, children: listScreens),
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              fixedColor: Colors.blue,
              unselectedItemColor: Colors.blueGrey,
              currentIndex: tabIndex,
              onTap: (int index) {
                setState(() {
                  tabIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text('Kryesore'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  title: Text('Peticion'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.info_outline),
                  title: Text('Rreth nesh'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.exit_to_app),
                  title: Text('Dil'),

                ),


              ]),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
