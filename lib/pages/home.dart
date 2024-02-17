import 'package:flutter/material.dart';

class Home extends StatefulWidget {


  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/chess.jpg'),
              fit: BoxFit.cover,
            ),
          ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(55,130,55,0),
              child: Column(
                children: <Widget>[
                  Text('Play Game',
                    style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'Sora',
                      color: Colors.grey[300],
                    ),
                  ),
                  Divider(
                    height: 60,
                    color: Colors.grey[300],
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await Navigator.pushNamed(context, '/game');
                      } catch (e) {
                        print('Error navigating to /game: $e');
                      };
                    },
                    child: Text('Get Started',
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Sora',
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                  Divider(
                    height: 50,
                    color: Colors.grey[200],
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await Navigator.pushNamed(context, '/records');
                      } catch (e) {
                        print('Error navigating to /game: $e');
                      };
                    },
                    child: Text('Game Records',
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Sora',
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
