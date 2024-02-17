import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:mind_mate/pages/records.dart';


class PlayMate extends StatefulWidget {

  @override
  State<PlayMate> createState() {
    return _PlayMateState();
  }

}

class _PlayMateState extends State<PlayMate> {


  int selectedStyleIndex = 0;

  CustomChessController? customChessController;

  final ScrollController scrollController = ScrollController();
  List<String> moves = [];
  List<BoardArrow> arrows = [];
  bool showArrowsEnabled = false;
  BoardColor chessBoard_color = BoardColor.green;
  ui.Color appBar_color = Colors.blueGrey.shade200;
  ui.Color buttons_color = Colors.cyan.shade700;
  ui.Color background_color = Colors.blueGrey.shade100;
  ui.Color buttonText_color = Colors.white;
  String? currentGameFileName;
  late Map<String, dynamic> jsonData;

  List styles = [
    Appearance(name: 'Rough Sea',
        chessBoard_color: BoardColor.green,
        appBar_color: Colors.blueGrey.shade200,
        background_color: Colors.blueGrey.shade100,
        buttons_color: Colors.cyan.shade700,
        buttonText_color: Colors.white),
    Appearance(name: 'Willy Wonka',
        chessBoard_color: BoardColor.brown,
        appBar_color: Colors.amber.shade100,
        background_color: Colors.amber.shade50,
        buttons_color: Colors.brown.shade600,
        buttonText_color: Colors.white),
    Appearance(name: 'Orange',
        chessBoard_color: BoardColor.orange,
        appBar_color: Colors.amber.shade600,
        background_color: Colors.amber.shade300,
        buttons_color: Colors.orange.shade800,
        buttonText_color: Colors.black),
    Appearance(name: 'Dark Chocolate',
        chessBoard_color: BoardColor.darkBrown,
        appBar_color: Colors.amber.shade50,
        background_color: Colors.brown.shade300,
        buttons_color: Colors.brown.shade900,
        buttonText_color: Colors.brown.shade100),
  ];


  void onAppearanceChanged(int selectedIndex) {
    setState(() {
      selectedStyleIndex = selectedIndex;
      styles[selectedIndex].changeAppearance(onAppearanceChangedCallback);
    });
  }

  void onAppearanceChangedCallback() {
    // Zainicjowanie zmiennych przy zmianie stanu aplikacji
    setState(() {
      chessBoard_color = styles[selectedStyleIndex].chessBoard_color;
      appBar_color = styles[selectedStyleIndex].appBar_color;
      buttons_color = styles[selectedStyleIndex].buttons_color;
      background_color = styles[selectedStyleIndex].background_color;
      buttonText_color = styles[selectedStyleIndex].buttonText_color;
    });

  }


  void chooseAppearance(BuildContext context,
      Function(int) onAppearanceChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Customize Appearance',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: styles.length,
              itemBuilder: (context, index) {
                return TextButton(
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      styles[index].name ?? 'Cannot Load',
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ),
                  onPressed: () {
                    onAppearanceChanged(index);

                    // konwersja instacji obiektu klasy Appearance do formatu JSON z użyciem metody toJson
                    String jsonString = json.encode(styles[index].toJson());

                    // Nadpisanie tych danych w formacie JSON do pliku app_data.json
                    writeJsonToFile(jsonString);

                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void writeJsonToFile(String jsonString) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final File jsonFile = File('${directory.path}/app_data.json');


      await jsonFile.writeAsString(jsonString);

      print('JSON file updated successfully.');
    } catch (e) {
      print('Error writing JSON file: $e');
    }
  }



  void updateMoves(String move) {
    if (!showArrowsEnabled) {
      String sanitizedMove = move.replaceAll(RegExp(r'^\d+\.\s*'), '');
      if (customChessController?.chessBoardController.game.turn == Chess.WHITE) {

        moves.add(sanitizedMove);
      } else if (moves.isNotEmpty) {
        moves[moves.length - 1] += ' $sanitizedMove';
      }

    }

    if (showArrowsEnabled) {
      String sanitizedMove = move.replaceAll(RegExp(r'^\d+\.\s*'), '');
      if (customChessController?.chessBoardController.game.turn == Chess.WHITE) {
        moves.add(sanitizedMove);
      } else if (moves.isNotEmpty) {
        moves[moves.length - 1] += ' $sanitizedMove';
      }

      showArrow();
    }
  }


  void showArrow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (moves.isNotEmpty) {
        List<String> squares = moves.last.split(' ');
        if (squares.length >= 2) {
          String fromSquare = squares[0];
          String toSquare = squares[1];

          arrows = [
            BoardArrow(
              from: fromSquare,
              to: toSquare,
              color: Colors.red.withOpacity(0.7),
            ),
          ];
        }
      }
      setState(() {});
    });
  }


  @override
  void initState() {
    super.initState();

    // Odczytywanie pliku z biblioteki aplikacji
    openJsonFile().then((_) {
      // Przypisanie zmiennych wartości na podstawie danych z pliku JSON lub użycie domyślnych wartości
      setState(() {

        //Tworzenie instancji klasy CustomChessController z listą moves
        customChessController = CustomChessController(moves: moves);

        chessBoard_color = jsonData['chessBoard_color'] != null
            ? BoardColor.values.firstWhere(
              (e) => e.toString() == jsonData['chessBoard_color'],
          orElse: () => BoardColor.green,
        )
            : BoardColor.green;

        buttonText_color = jsonData['buttonText_color'] != null
            ? colorFromString(jsonData['buttonText_color'])
            : Colors.white;

        buttons_color = jsonData['buttons_color'] != null
            ? colorFromString(jsonData['buttons_color'])
            : Colors.cyan.shade700;

        appBar_color = jsonData['appBar_color'] != null
            ? colorFromString(jsonData['appBar_color'])
            : Colors.blueGrey.shade200;


        background_color = jsonData['background_color'] != null
            ? colorFromString(jsonData['background_color'])
            : Colors.blueGrey.shade100;


      });
    });
  }


  Future<void> openJsonFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final File jsonFile = File('${directory.path}/app_data.json');

      print('path: ${directory.path}');
      String jsonString = await jsonFile.readAsString();


      jsonData = json.decode(jsonString);

      // Wyświetl zawartość pliku JSON lub błąd jeśli będzie
      print('JSON file content: $jsonData');
    } catch (e) {
      print('Error opening/reading JSON file: $e');
    }
  }


  void saveMovesToJson(context) async {


      try {
        if (moves.isEmpty) {
          showMessage(context, 'No moves to save');
          print('No moves to save.');
          return;
        }

      final directory = await getApplicationDocumentsDirectory();
      String fileName;

      if (currentGameFileName == null) {
        int fileNumber = 1;
        do {
          fileName = '${directory.path}/moves_$fileNumber.json';
          fileNumber++;
        } while (File(fileName).existsSync());
        currentGameFileName = fileName;
      } else {
        fileName = currentGameFileName!;
      }

      var sanMoves = customChessController?.chessBoardController.getSan();
      print('SanMoves: $sanMoves');
      String jsonString = json.encode(sanMoves);

      await File(fileName).writeAsString(jsonString);

      showMessage(context, 'Moves saved successfully.');
      print('Moves saved to $fileName successfully.');


      String fileContent = await File(fileName).readAsString();
      print('JSON file content: $fileContent');
    } catch (e) {
      print('Error writing JSON file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: const Text(
          'Game',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 24,
          ),
        ),
        backgroundColor: appBar_color,
        titleTextStyle: TextStyle(
          fontFamily: 'Sora',
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        right: false,
        left: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: ChessBoard(
                controller: customChessController!.chessBoardController,
                boardColor: chessBoard_color,
                arrows: showArrowsEnabled ? arrows : [],
              ),
            ),
            SizedBox(height: 25),
            Container(
              height: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: ValueListenableBuilder<Chess>(
                        valueListenable:customChessController?.chessBoardController ?? ValueNotifier<Chess>(Chess()),
                        builder: (context, game, _) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) {
                            scrollController.jumpTo(scrollController
                                .position.maxScrollExtent);
                          });
                          return Padding(
                            padding:
                            const EdgeInsets.fromLTRB(25, 0, 0, 0),
                            child: ListView(
                              shrinkWrap: true,
                              children: customChessController?.chessBoardController.getSan().map((move) {
                                updateMoves(move ?? '');
                                print(move ?? '');
                                return Text(
                                  move ?? '',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                  ),
                                );
                              }).toList() ?? [],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: buttons_color,
                          ),
                          onPressed: () {
                            setState(() {
                              showArrowsEnabled = false;
                              customChessController?.undoMove();
                              arrows.clear();
                            });
                          },
                          child: Text(
                            'Move back',
                            style: TextStyle(
                              color: buttonText_color,
                              fontFamily: 'Sora',
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: buttons_color,
                          ),
                          onPressed: () {
                            setState(() {
                              showArrowsEnabled = !showArrowsEnabled;
                              if (!showArrowsEnabled) {
                                arrows.clear();
                              }
                              if (showArrowsEnabled) {
                                showArrow();
                              }
                            });
                          },
                          child: Center(
                            child: Text(
                              showArrowsEnabled
                                  ? 'Hide Arrows'
                                  : 'Show Arrows',
                              style: TextStyle(
                                color: buttonText_color,
                                fontFamily: 'Sora',
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: buttons_color,
                          ),
                          onPressed: () {
                            saveMovesToJson(context);
                          },
                          child: Text(
                            'Save Game State',
                            style: TextStyle(
                              color: buttonText_color,
                              fontFamily: 'Sora',
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: buttons_color,
                          ),
                          onPressed: () {
                            chooseAppearance(
                                context, onAppearanceChanged);
                          },
                          child: Center(
                            child: Text(
                              'Cutomize Appearance',
                              style: TextStyle(
                                color: buttonText_color,
                                fontFamily: 'Sora',
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomChessController {
  final ChessBoardController chessBoardController = ChessBoardController();


  // Lista moves jest utworzona w klasie _PlayMateState, więc musimy zrobić do niej referencję

  final List<String> moves;

  CustomChessController({required this.moves});

  void undoMove() {
    if (chessBoardController.game.history.isNotEmpty) {

      // Undo the move
      chessBoardController.game.undo();

      chessBoardController.notifyListeners();
      moves.removeLast();
    }
  }
}


class Appearance {

  String? name;
  var appBar_color;
  var buttons_color;
  BoardColor? chessBoard_color;
  var background_color;
  var buttonText_color;

  Appearance(
      {this.name, this.appBar_color, this.buttons_color, this.chessBoard_color, this.background_color, this.buttonText_color});


  void changeAppearance(Function onAppearanceChangedCallback) {
    onAppearanceChangedCallback();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'appBar_color': colorToName(appBar_color),
      'buttons_color': colorToName(buttons_color),
      'chessBoard_color': chessBoard_color.toString(),
      'background_color': colorToName(background_color),
      'buttonText_color': colorToName(buttonText_color),
    };

  }


}

ui.Color colorFromString(String colorString) {
  switch (colorString) {
    case 'Colors.amber.shade100':
      return Colors.amber.shade100;
    case 'Colors.amber.shade50':
      return Colors.amber.shade50;
    case 'Colors.brown.shade600':
      return Colors.brown.shade600;
    case 'Colors.brown.shade100':
      return Colors.brown.shade100;
    case 'Colors.white':
      return Colors.white;
    case 'Colors.blueGrey.shade100':
      return Colors.blueGrey.shade100;
    case 'Colors.blueGrey.shade200':
      return Colors.blueGrey.shade200;
    case 'Colors.black':
      return Colors.black;
    case 'Colors.amber.shade300':
      return Colors.amber.shade300;
    case 'Colors.amber.shade600':
      return Colors.amber.shade600;
    case 'Colors.brown.shade300':
      return Colors.brown.shade300;
    case 'Colors.brown.shade900':
      return Colors.brown.shade900;
    case 'Colors.cyan.shade700':
      return Colors.cyan.shade700;
    case 'Colors.orange.shade800':
      return Colors.orange.shade800;
    default:
      return Colors.black; // Kolor domyślny jeżeli powyższe nie znajdą dopasowania
  }
}

dynamic colorToName(dynamic color) {
  if (color == Colors.amber.shade100) {
    return 'Colors.amber.shade100';
  } else if (color == Colors.amber.shade50) {
    return 'Colors.amber.shade50';
  } else if (color == Colors.brown.shade600) {
    return 'Colors.brown.shade600';
  } else if (color == Colors.white) {
    return 'Colors.white';
  } else if (color == Colors.blueGrey.shade100) {
    return 'Colors.blueGrey.shade100';
  } else if (color == Colors.blueGrey.shade200) {
    return 'Colors.blueGrey.shade200';
  } else if (color == Colors.black) {
    return 'Colors.black';
  } else if (color == Colors.amber.shade300) {
    return 'Colors.amber.shade300';
  } else if (color == Colors.amber.shade600) {
    return 'Colors.amber.shade600';
  } else if (color == Colors.brown.shade300) {
    return 'Colors.brown.shade300';
  } else if (color == Colors.brown.shade900) {
    return 'Colors.brown.shade900';
  } else if (color == Colors.brown.shade100) {
    return 'Colors.brown.shade100';
  } else if (color == Colors.cyan.shade700) {
    return 'Colors.cyan.shade700';
  } else if (color == Colors.orange.shade800) {
    return 'Colors.orange.shade800';
  }
}


