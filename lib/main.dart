import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Event {
  final String image_src;
  final String title;
  final String description;

  Event({this.title, this.description, this.image_src});
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = Tween<double>(begin: 0, end: 100).animate(controller)
      ..addListener(() {
        setState(() {
          if (animation.value >= 20) {
            adx = 0;
            ady = 0;
            dx = 0;
            dy = 0;

            theta = 0;
            debugPrint(events.length.toString());
            events.removeAt(0);
            controller.stop();
          } else {
            if (dx < 0) {
              adx = -animation.value * 30;
            } else {
              adx = animation.value * 30;
            }
            theta = ((adx + dx) / midX) * (math.pi / 10);
          }
        });
      });
  }

  _MyHomePageState() {
    this.events = List<Event>.generate(
      20,
      (i) => Event(
          title: 'Event $i',
          description: 'A description of Event $i',
          image_src: 'https://source.unsplash.com/random'),
    );
  }

  double dx = 0;
  double dy = 0;
  double xoffset = 0;
  double yoffset = 0;
  double theta = 0;
  double width = 0;
  double height = 0;
  double midX = 0;
  double adx = 0;
  double ady = 0;
  double gradient = 0;
  List<Event> events;

  Velocity finalVel;
  void startGesture(double x, double y) {
    controller.reset();
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      xoffset = x;
      yoffset = y;
    });
  }

  void stopGesture(Velocity velocity) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

      finalVel = velocity;
    });
    controller.forward();
  }

  void updateGesture(double x, double y) {
    debugPrint(dx.toString());
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      dx = x - xoffset;
      dy = y - yoffset;

      theta = (dx / midX) * (math.pi / 10);
    });
  }

  List<Widget> viewable_events() {
    if (events.length >= 3) {
      return [
        Positioned(
            top: 20,
            left: 40,
            child: EventCard(
                image_src: events[2].image_src,
                title: events[2].title,
                description: events[2].description,
                width: width - 100,
                height: (height * (2 / 3)) - 20)),
        Positioned(
            top: 35,
            left: 20,
            child: EventCard(
                image_src: events[1].image_src,
                title: events[1].title,
                description: events[1].description,
                width: width - 60,
                height: (height * (2 / 3)) - 20)),
        Positioned(
            top: 50 + dy.toDouble() + ady,
            left: dx.toDouble() + adx,
            child: Transform.rotate(
                angle: theta,
                child: EventCard(
                    image_src: events[0].image_src,
                    title: events[0].title,
                    description: events[0].description,
                    width: width - 20,
                    height: (height * (2 / 3)) - 20)))
      ];
    } else if (events.length == 2) {
      return [
        Positioned(
            top: 35,
            left: 20,
            child: EventCard(
                image_src: events[1].image_src,
                title: events[1].title,
                description: events[1].description,
                width: width - 60,
                height: (height * (2 / 3)) - 20)),
        Positioned(
            top: 50 + dy.toDouble() + ady,
            left: dx.toDouble() + adx,
            child: Transform.rotate(
                angle: theta,
                child: EventCard(
                    image_src: events[0].image_src,
                    title: events[0].title,
                    description: events[0].description,
                    width: width - 20,
                    height: (height * (2 / 3)) - 20)))
      ];
    } else if (events.length == 1) {
      return [
        Positioned(
            top: 50 + dy.toDouble() + ady,
            left: dx.toDouble() + adx,
            child: Transform.rotate(
                angle: theta,
                child: EventCard(
                    image_src: events[0].image_src,
                    title: events[0].title,
                    description: events[0].description,
                    width: width - 20,
                    height: (height * (2 / 3)) - 20)))
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    midX = width / 2;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Column(children: [
      Flexible(
          child: new Container(
              decoration: new BoxDecoration(color: Colors.white),
              child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    startGesture(
                        details.globalPosition.dx, details.globalPosition.dy);
                  },
                  onHorizontalDragEnd: (details) {
                    stopGesture(details.velocity);
                  },
                  onHorizontalDragUpdate: (details) {
                    updateGesture(
                        details.globalPosition.dx, details.globalPosition.dy);
                  },

                  // Center is a layout widget. It takes a single child and positions it
                  // in the middle of the parent.

                  child: Stack(
                    children: viewable_events(),
                  )))),
      Container(
          decoration: new BoxDecoration(color: Colors.white),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: () {
                dx = -1;
                controller.reset();

                controller.forward();
              },
              child: Container(
                margin: const EdgeInsets.all(20.0),
                width: 100.0,
                height: 100.0,
                decoration: new BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                dx = 1;
                controller.reset();
                controller.forward();
              },
              child: Container(
                margin: const EdgeInsets.all(20.0),
                width: 100.0,
                height: 100.0,
                decoration: new BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ]))
    ]);
  }
}

class EventCard extends StatelessWidget {
  EventCard(
      {this.image_src, this.title, this.description, this.width, this.height});
  String image_src;
  String title;
  String description;
  double width;
  double height;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10.0),
        width: this.width,
        height: this.height,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                  child: ClipRRect(
                borderRadius: new BorderRadius.circular(16.0),
                child: Image.network(
                  this.image_src,
                  fit: BoxFit.cover,
                ),
              )),
              Container(
                  margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    this.title,
                    style: TextStyle(fontSize: 21),
                    textAlign: TextAlign.left,
                  )),
              Container(
                  margin: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                  alignment: Alignment.centerLeft,
                  child: Text(this.description,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left))
            ],
          ),
        ));
  }
}
