import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'api.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:geo_location_finder/geo_location_finder.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());
const cardHeightFactor = 4 / 5;

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
  String image_src;
  String title;
  String description;
  double lat;
  double long;
  var price;
  String name;
  String website;
  double euclid_dist;
  List<String> performance_dates;
  bool seen = false;
  bool liked = false;
  Event({this.title, this.description, this.image_src});
  void swiped(bool liked) {
    this.seen = true;
    this.liked = liked;
  }
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  Offset currentDrag = Offset(0.0, 0.0);
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (currentDrag.dx < 0) {
          events.firstWhere((e) => !e.seen).swiped(false);
        } else {
          events.firstWhere((e) => !e.seen).swiped(true);
        }

        theta = 0;
        ignore = false;
        hide_buttons = false;
        adx = 0;
        ady = 0;
        currentDrag = Offset(0, 0);
      }
    });
    controller.addListener(() {
      setState(() {
        if (currentDrag.dx < 0) {
          adx = -animation.value * 3;
        } else {
          adx = animation.value * 3;
        }
        theta = ((adx + currentDrag.dx) / midX) * (math.pi / 10);
      });
    });
    api();
  }

  Future<List<Event>> api() async {
    var result = await Search();
    var currentLocation;
    Map<dynamic, dynamic> locationMap;
    double cur_lat;
    double cur_long;

    try {
      locationMap = await GeoLocation.getLocation;
      var status = locationMap["status"];
      if ((status is String && status == "true") ||
          (status is bool) && status) {
        var lat = locationMap["latitude"];
        var lng = locationMap["longitude"];

        if (lat is String) {
          cur_lat = double.parse(lat);
          cur_long = double.parse(lng);
        } else {
          // lat and lng are not string, you need to check the data type and use accordingly.
          // it might possible that else will be called in Android as we are getting double from it.
          cur_lat = double.parse(lat);
          cur_long = double.parse(lng);
        }
      } else {
        result = locationMap["message"];
      }
    } catch (e) {
      cur_lat = 55.9431985;
      cur_long = -3.2003548;
    }
    debugPrint(cur_lat.toString() + ":" + cur_long.toString());
    List<Event> es = [];

    for (var i = 0; i < result.length; i++) {
      Event event = new Event();
      var currentevent = result[i];
      event.lat = currentevent['latitude'];
      event.long = currentevent['longitude'];
      event.description = currentevent['description'];
      event.title = currentevent['title'];
      event.website = currentevent['website'];
      event.name = currentevent['venue']['name'];
      event.performance_dates = [];
      event.price = currentevent['performances'][0]['price'];
      var performances = currentevent['performances'];
      for (var j = 0; j < performances.length; j++) {
        var currentshow = currentevent['performances'][j];
        event.performance_dates.add(currentshow['start']);
      }
      event.euclid_dist =
          math.pow(event.lat - cur_lat, 2) + math.pow(event.long - cur_long, 2);
      if (currentevent['images'] != null) {
        var imgkeys = currentevent['images'].values.toList();

        event.image_src = "https:" + imgkeys[0]['versions']['original']['url'];
      } else {
        event.image_src = "https://source.unsplash.com/random";
      }
      es.add(event);
    }
    es.sort((a, b) => a.euclid_dist.compareTo(b.euclid_dist));
    setState(() {
      events = es;
    });
  }

  double xoffset = 0;
  double yoffset = 0;
  double theta = 0;
  double width = 0;
  double height = 0;
  double midX = 0;
  double adx = 0;
  double ady = 0;
  bool ignore = false;
  bool hide_buttons = false;
  double gradient = 0;
  List<Event> events = [];

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
      if (height - yoffset < 100) {
        ignore = true;
      } else {
        ignore = false;
        hide_buttons = true;
      }
    });
  }

  void stopGesture(Velocity velocity) {
    if (!ignore) {
      setState(() {
        hide_buttons = false;
        // This call to setState tells the Flutter framework that something has
        // changed in this State, which causes it to rerun the build method below
        // so that the display can reflect the updated values. If we changed
        // _counter without calling setState(), then the build method would not be
        // called again, and so nothing would appear to happen.

        finalVel = velocity;
        if (currentDrag.dy > 100 &&
            math.sqrt(math.pow(currentDrag.dx, 2)) < 50) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EventDetail(
                      image_src: events[0].image_src,
                      title: events[0].title,
                      description: events[0].description,
                      width: width - 20,
                      website: events[0].website,
                      name: events[0].name,
                      price: events[0].price,
                      performance_times: events[0].performance_dates,
                      height: (height * (cardHeightFactor)) - 20)));
          adx = 0;
          ady = 0;
          currentDrag = Offset(0.0, 0.0);

          theta = 0;
        } else if (finalVel.pixelsPerSecond.distanceSquared > 50) {
          controller.forward();
        } else {
          adx = 0;
          ady = 0;
          currentDrag = Offset(0.0, 0.0);
          theta = 0;
        }
      });
    }
  }

  void updateGesture(double x, double y) {
    if (!ignore) {
      setState(() {
        // This call to setState tells the Flutter framework that something has
        // changed in this State, which causes it to rerun the build method below
        // so that the display can reflect the updated values. If we changed
        // _counter without calling setState(), then the build method would not be
        // called again, and so nothing would appear to happen.
        currentDrag = Offset(x - xoffset, y - yoffset);

        theta = (currentDrag.dx / midX) * (math.pi / 10);
      });
    }
  }

  Widget buildButtons() {
    return !hide_buttons
        ? Positioned(
            bottom: 0,
            width: width,
            child: Container(
                decoration: new BoxDecoration(color: Colors.transparent),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          currentDrag = Offset(-100.0, 0.0);
                          controller.reset();

                          controller.forward();
                        },
                        child: Container(
                            margin: const EdgeInsets.all(20.0),
                            width: 60.0,
                            height: 60.0,
                            child: Icon(
                              Icons.clear,
                              size: 48,
                              color: Colors.white,
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      History(events: events)));
                        },
                        child: Container(
                            margin: const EdgeInsets.all(20.0),
                            width: 60.0,
                            height: 60.0,
                            child: Icon(
                              Icons.star,
                              size: 36,
                              color: Colors.white,
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          currentDrag = Offset(100.0, 0.0);
                          controller.reset();
                          controller.forward();
                        },
                        child: Container(
                            margin: const EdgeInsets.all(20.0),
                            width: 60.0,
                            height: 60.0,
                            child: Icon(Icons.check,
                                size: 48, color: Colors.white)),
                      ),
                    ])))
        : Container();
  }

  List<Widget> viewable_events() {
    var non_viewed = events.where((e) {
      return e.seen == false;
    }).toList();
    return non_viewed.length >= 3
        ? [
            Positioned(
                top: 20,
                left: 40,
                child: EventCard(
                    image_src: non_viewed[2].image_src,
                    title: non_viewed[2].title,
                    description: non_viewed[2].description,
                    price: non_viewed[2].price,
                    width: width - 100,
                    height: (height * (cardHeightFactor)) - 20)),
            Positioned(
                top: 35,
                left: 20,
                child: EventCard(
                    image_src: non_viewed[1].image_src,
                    title: non_viewed[1].title,
                    price: non_viewed[2].price,
                    description: non_viewed[1].description,
                    width: width - 60,
                    height: (height * (cardHeightFactor)) - 20)),
            Positioned(
                top: 50 + currentDrag.dy.toDouble() + ady,
                left: currentDrag.dx.toDouble() + adx,
                child: Transform.rotate(
                    angle: theta,
                    child: EventCard(
                        image_src: non_viewed[0].image_src,
                        title: non_viewed[0].title,
                        description: non_viewed[0].description,
                        width: width - 20,
                        price: non_viewed[2].price,
                        height: (height * (cardHeightFactor)) - 20))),
            buildButtons()
          ]
        : [Container()];
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(events.length.toString());
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
              color: Colors.pink,
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
    ]);
  }
}

class EventCard extends StatelessWidget {
  EventCard(
      {this.image_src,
      this.title,
      this.description,
      this.price,
      this.width,
      this.height});
  String image_src;
  String title;
  String description;
  double width;
  double height;
  var price;
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
                  margin: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 4.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    this.title,
                    style: TextStyle(fontSize: 21),
                    textAlign: TextAlign.left,
                  )),
              Container(
                  margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "£" + this.price.toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )),
              Container(
                  margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  alignment: Alignment.centerLeft,
                  child: Html(data: this.description))
            ],
          ),
        ));
  }
}

// class TimeTablingCard extends StatelessWidget {
//   TimeTablingCard({this.times, this.name, this.width});
//   List<String> times;
//   String name;
//   double width

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         margin: const EdgeInsets.fromLTRB(10.0, 0, 10, 10),
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Flexible(
//                 child: Text(
//                   this.name,
//                   style: TextStyle(
//                       fontSize: 21,
//                       color: Colors.pink,
//                       decoration: TextDecoration.none),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }
// }

class EventDetail extends StatelessWidget {
  EventDetail(
      {this.image_src,
      this.title,
      this.description,
      this.width,
      this.height,
      this.website,
      this.name,
      this.price,
      this.performance_times});
  String image_src;
  String title;
  String website;
  String description;
  String name;
  var price;
  List<String> performance_times;
  double width;
  double height;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PageView(
      controller: PageController(initialPage: 0),
      children: <Widget>[
        Container(
            color: Colors.cyan,
            child: Column(children: [
              Expanded(
                  child: EventCard(
                image_src: image_src,
                title: title,
                description: description,
                price: price,
                width: width,
                height: height,
              )),
              // Expanded(
              //     child: TimeTablingCard(times: performance_times, name: name)),
              GestureDetector(
                  onTap: () {
                    _launchURL(website); //launch(eve)
                  },
                  child: Container(
                      decoration: new BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius:
                              new BorderRadius.all(Radius.circular(16))),
                      margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                      height: 60,
                      width: width,
                      child: Center(
                        child: Text(
                          "Book Now",
                          style: TextStyle(
                              fontSize: 21,
                              color: Colors.white,
                              background: Paint()..color = Colors.deepPurple,
                              decoration: TextDecoration.none),
                          textAlign: TextAlign.center,
                        ),
                      )))
            ])),
      ],
    );
  }
}

_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    debugPrint('Could not launch $url');
  }
}

class History extends StatelessWidget {
  History({this.events});
  List<Event> events;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.deepPurple,
        child: ListView(
            children: events
                .where((e) => e.seen && e.liked)
                .map((e) => EventListItem(event: e))
                .toList()));
  }
}

class EventListItem extends StatelessWidget {
  EventListItem({this.event});
  Event event;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventDetail(
                      image_src: event.image_src,
                      title: event.title,
                      description: event.description,
                      website: event.website,
                      name: event.name,
                      price: event.price,
                      performance_times: event.performance_dates,
                    )));
      },
      child: Container(
          margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.all(10.0),
                    height: 64,
                    width: 64,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(64.0),
                      child: Image.network(
                        this.event.image_src,
                        fit: BoxFit.cover,
                      ),
                    )),
                Flexible(
                  child: Text(
                    this.event.title,
                    style: TextStyle(fontSize: 21),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
