import 'package:flutter/material.dart';
import './components/ball.dart';
import './components/bat.dart';

enum Direction { up, left, down, right }

class Pong extends StatefulWidget {
  @override
  _PongState createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  Direction vDir = Direction.down;
  Direction hDir = Direction.right;
  double width,
      height,
      posX,
      posY,
      batWidht,
      batHeight,
      batPosition = 0,
      increament = 5;
  Animation<double> animation;
  AnimationController controller;
  int score = 0;

  @override
  void initState() {
    super.initState();
    posX = 0;
    posY = 0;
    controller = AnimationController(
      duration: const Duration(minutes: 10000),
      vsync: this,
    );
    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    animation.addListener(() {
      setState(() {
        (hDir == Direction.right) ? posX += increament : posX -= increament;
        (vDir == Direction.down) ? posY += increament : posY -= increament;
      });
      checkBorders();
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        batWidht = width / 5;
        batHeight = height / 20;
        return Scaffold(
          appBar: AppBar(
            title: Text('Pong 2D'),
            actions: [
              Center(
                child: Text(
                  'Score: ' + score.toString(),
                  style: TextStyle(fontSize: 24),
                ),
              )
            ],
          ),
          body: Stack(
            children: <Widget>[
              Positioned(
                child: Ball(),
                top: posY,
                left: posX,
              ),
              Positioned(
                bottom: 0,
                left: batPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (DragUpdateDetails update) =>
                      moveBat(update),
                  child: Bat(batWidht, batHeight),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void checkBorders() {
    double diameter = 50;
    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
    }
    if (posX >= width - diameter && hDir == Direction.right) {
      hDir = Direction.left;
    }
    if (posY >= height - diameter - (batHeight * 2.5) &&
        vDir == Direction.down) {
      if (posX >= (batPosition - diameter) &&
          posX <= (batPosition + batWidht + diameter)) {
        vDir = Direction.up;

        setState(() {
          score++;
        });
      } else {
        controller.stop();
        showMessage(context);
      }
      vDir = Direction.up;
    }

    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
    }
  }

  void moveBat(DragUpdateDetails update) {
    setState(() {
      batPosition += update.delta.dx;
    });
  }

  void showMessage(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('Would you like to play again?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  setState(() {
                    posX = 0;
                    posY = 0;
                    score = 0;
                  });
                  Navigator.of(context).pop();
                  controller.repeat();
                },
              ),
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                  dispose();
                },
              )
            ],
          );
        });
  }
}
