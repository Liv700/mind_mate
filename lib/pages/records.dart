import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class GameRecords extends StatefulWidget {

  @override
  State<GameRecords> createState() => _GameRecordsState();
}

class _GameRecordsState extends State<GameRecords> {
  bool showBorder = true;
  late int latestFileNumber;




// Funkcja do pokazania zawartości pliku moves_x.json w oknie dialogowym
  Future<void> showMovesContent(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$fileName.json');

      // Odczyt danych JSNO z pliku
      String jsonString = await file.readAsString();

      // Konwersja JSON string tna listę ruchów
      List<dynamic> movesList = json.decode(jsonString);

      // Formatowanie listy ruchów do wyświetlenia
      String formattedContent = movesList.join('\n');

      // Wyświetlanie okna dialogowego z zawartością
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                'Your moves:',
                style: TextStyle(
                  fontFamily: 'Sora',
                ),
            ),
            content: Text(
              formattedContent,
              style: TextStyle(
                fontFamily: 'Sora',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  Future<void> getLatestFileNumber() async {
    try {
      final directory = Directory((await getApplicationDocumentsDirectory()).path);

      // Wylistowanie wszystkich plików w plikach aplikcaji
      List<FileSystemEntity> files = directory.listSync();

      // Inicjalizacja od najmniejszego
      latestFileNumber = 0;

      // Iteracja przez pliki, aby znaleźć plik moves_x.json z największym x
      for (var file in files) {
        if (file is File && file.path.contains('moves_') && file.path.endsWith('.json')) {
          String fileName = file.path.split('/').last;
          int fileNumber = int.parse(fileName.split('_').last.split('.').first);
          latestFileNumber = latestFileNumber < fileNumber ? fileNumber : latestFileNumber;
        }
      }

      setState(() {});
    } catch (e) {
      print('Error getting latest file number: $e');
    }
  }

  Future<void> deleteAllRecords(BuildContext context) async {
    try {
      print('Context in deleteAllRecords: $context');
      final directory = Directory('${(await getApplicationDocumentsDirectory()).path}');
      bool deleted = false;

      // Wylistowanie wszystkich plików w plikach aplikcaji
      List<FileSystemEntity> files = directory.listSync();

      // Iteracja przez wszystkie pliki w celu usunięcia plików moves_x.json
      for (var file in files) {
        if (file is File && file.path.contains('moves_') && file.path.endsWith('.json')) {
          await file.delete();
          deleted = true;
        }
      }

      if (deleted) {
        // Pokaż komunikat na ekranie
        showMessage(context, 'All records deleted successfully.');
        await getLatestFileNumber();
      } else {
        showMessage(context, 'No records to delete!');
      }
    } catch (e) {
      print('Error deleting records: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getLatestFileNumber();
  }


  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Games',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontFamily: 'Sora',
            ),
          ),
          backgroundColor: Colors.lime.shade400.withOpacity(0.7),
          iconTheme: IconThemeData(color: Colors.blue.shade600),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/blue.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: latestFileNumber,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                              child: TextButton(
                                onPressed: () {
                                  showMovesContent('moves_${index + 1}');
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade400
                                      .withOpacity(0.5),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Game ${index+1}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 30,
                                      fontFamily: 'Sora',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 15, 25),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.lime.shade600.withOpacity(
                                  0.5),
                            ),
                            onPressed: () async {
                              await deleteAllRecords(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Text(
                                'Delete All Records',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Sora',
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: showBorder ? 5 : 0,
                width: double.infinity,
                color: showBorder ? Colors.lime.shade300.withOpacity(0.5) : Colors
                    .transparent,
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: showBorder ? 10 : 0,
                width: double.infinity,
                color: showBorder ? Colors.lime.shade300.withOpacity(0.4) : Colors
                    .transparent,
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: showBorder ? 15 : 0,
                width: double.infinity,
                color: showBorder ? Colors.lime.shade300.withOpacity(0.3) : Colors
                    .transparent,
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: showBorder ? 20 : 0,
                width: double.infinity,
                color: showBorder ? Colors.lime.shade300.withOpacity(0.3) : Colors
                    .transparent,
              ),
            ],
          ),
        ),
      );
    }
  }


void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 20,
          ),
        ),
      ),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.25,
        horizontal: MediaQuery.of(context).size.width * 0.1,
      ),
      backgroundColor: Colors.grey.shade800.withOpacity(0.5),
    ),
  );
}
