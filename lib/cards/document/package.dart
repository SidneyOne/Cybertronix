import 'package:flutter/material.dart';
import 'package:firebase_firestore/firebase_firestore.dart';


/// A detailed card with all the info about a panel package, returned
/// from Firebase, organized into [ExpansionPanel]s.
class PackageInfoCard extends StatelessWidget {

  /// This info comes direct from the location card's data
  final DocumentSnapshot packageData;

  /// A detailed card with all the info about a panel package, returned
  /// from Firebase, organized into [ExpansionPanel]s.
  PackageInfoCard(this.packageData);

  /// This is a cheap way to make my Firebase names look better
  final Map<String, String> prettify = <String, String>{
    "manufacturer": "Manufacturer",
    "model": "Model #",
    "serial": "Serial #",
    "chargervolts": "AC Voltage",
    "enginevolts": "DC Voltage",
    "start": "Start Pressure",
    "stop": "Stop Pressure",
    "enclosure": "Enclosure Rating",
    "hp": "HP",
    "starting": "Starting Type",
    "volts": "AC Volts",
    "amps": "Amps",
    "phase": "Phase",
    "rpm": "RPM",
    "ground": "Ground",
    "shutoff": "Shutoff pressure",
    "rated": "Rated pressure",
    "over": "150% pressure",
  };

  /// This function takes a sub-object from the main Firebase object
  /// and returns a [ListTile].
  Widget packageTile(Map<String, dynamic> object, String key){
    return new ListTile(
      title: new Text(object[key].toString()),
      subtitle: new Text(prettify[key]),
    );
  }

  /// This takes the panel data returned from, and returns widgets for an
  /// [ExpansionTile]
  List<Widget> panelSubList(Map<String, dynamic> panel, String power){
    List<String> keyList;
    if (power == "Diesel"){
      keyList = <String>["manufacturer", "power", "model", "serial", "chargervolts", "enginevolts", "start", "stop", "enclosure"];
    } else {
      keyList = <String>["manufacturer", "power", "model", "serial", "hp", "volts", "phase", "starting", "start", "stop", "enclosure"];
    }
    return keyList.map((String key){
      if (key == "power"){
        return new ListTile(
          title: new Text(power),
          subtitle: new Text("Power")
        );
      }
      return packageTile(panel, key);
    }).toList();
  }

  List<Widget> _tswitchSubList(Map<String, dynamic> tswitch){
    return <String>["manufacturer", "model", "serial"].map((String key){
      return packageTile(tswitch, key);
    }).toList();
  }

  List<Widget> _pumpSubList(Map<String, dynamic> pump){
    return <String>["manufacturer", "model", "serial", "rpm", "shutoff", "rated", "over"].map((String key){
      return packageTile(pump, key);
    }).toList();
  }

  List<Widget> _motorSubList(Map<String, dynamic> motor, String power){
    List<String> keyList;
    if (power == "Diesel"){
      keyList = <String>["manufacturer", "power", "model", "serial", "hp", "rpm", "volts", "ground"];
    } else {
      keyList = <String>["manufacturer", "power", "model", "serial", "hp", "rpm", "volts", "amps", "phase"];
    }
    return keyList.map((String key){
      if (key == "power"){
        return new ListTile(
          title: new Text(power),
          subtitle: new Text("Power")
        );
      }
      return packageTile(motor, key);
    }).toList();
  }

  List<Widget> _jpanelSubList(Map<String, dynamic> jpanel){
    return <String>["manufacturer", "model", "serial", "hp", "start", "stop", "enclosure"].map((String key){
      return packageTile(jpanel, key);
    }).toList();
  }

  List<Widget> _jpumpSubList(Map<String, dynamic> jpump){
    return <String>["manufacturer", "model", "serial", "hp", "volts", "phase"].map((String key){
      return packageTile(jpump, key);
    }).toList();
  }

  List<Widget> _getLines(){
    List<Widget> lines = <Widget>[];
    if (packageData["panel"] != null) {
      lines.add(new ExpansionTile(
        title: new Text("Panel"),
        children: panelSubList(packageData["panel"], packageData["power"]),
      ));
    }
    if (packageData["tswitch"] != null){
      lines.add(new ExpansionTile(
        title: new Text("Transfer Switch"),
        children: _tswitchSubList(packageData["tswitch"]),
      ));
    }
    if (packageData["motor"] != null){
      lines.add(new ExpansionTile(
        title: new Text("Motor"),
        children: _motorSubList(packageData["motor"], packageData["power"]),
      ));
    }
    if (packageData["pump"] != null){
      lines.add(new ExpansionTile(
        title: new Text("Pump"),
        children: _pumpSubList(packageData["pump"]),
      ));
    }
    if (packageData["jockeypanel"] != null){
      List<Widget> jockeyWidgets = <Widget>[];
      jockeyWidgets.addAll(_jpanelSubList(packageData["jockeypanel"]));
      if (packageData["jockeypump"] != null){
        jockeyWidgets.addAll(_jpumpSubList(packageData["jockeyPump"]));
      }
      lines.add(new ExpansionTile(
        title: new Text("Jockey"),
        children: jockeyWidgets,
      ));
    }
    return lines;
  }

  @override
  Widget build(BuildContext build){
    return new Card(
      child: new Column(
        children: _getLines(),
      ),
    );
  }
}

class PackageSummaryCard extends StatefulWidget{
  final Map<String, dynamic> packageData;
  final Function(Map<String, dynamic>) changeCallback;
  final Function() removeCallback;

  // TODO: Figure out where to put this.

  PackageSummaryCard(this.packageData, this.changeCallback, this.removeCallback);

  @override
  _PackageSummaryCardState createState() => new _PackageSummaryCardState();
}

class _PackageSummaryCardState extends State<PackageSummaryCard>{
  Map<String, dynamic> packageData;

  @override
  void initState(){
    super.initState();
    packageData = widget.packageData;
  }

  List<Widget> _getLines(){
    List<Widget> lines = <Widget>[];
    if (packageData["panel"] != null){
      lines.add(new ListTile(
        title: new Text("${packageData["panel"]["manufacturer"]} ${packageData["power"]}")
      ));
      if (packageData["power"] == "Electric" && packageData["tswitch" != null]){
        lines.add(new ListTile(
          title: new Text("With Transfer Switch")
        ));
      }
    }
    if (packageData["motor"] != null){
      lines.add(new ListTile(
        title: new Text("${packageData["motor"]["manufacturer"]} ${packageData["power"] == "Diesel" ? "Engine" : "Motor"}"),
      ));
    }
    if (packageData["pump"] != null){
      lines.add(new ListTile(
        title: new Text("${packageData["pump"]["manufacturer"]}")
      ));
    }
    if (packageData["jockeypanel"] != null){
      lines.add(new ListTile(
        title: new Text("${packageData["jockeypanel"]["manufacturer"]} Jockey")
      ));
    }
    if (packageData["jockeypump"] != null){
      lines.add(new ListTile(
        title: new Text("${packageData["jockeypump"]["manufacturer"]} Jockey Pump")
      ));
    }
    lines.add(new ButtonBar(
      children: <Widget>[
        new FlatButton(
          child: new Text("Remove"),
          onPressed: () {
            // TODO: Popup Confirmation
            // TODO: Dismiss the card
            // Future: Animation to dismiss would be cool!
            // TODO: Remove the package from the location.
          },
        ),
        new FlatButton(
          child: new Text("Edit"),
          onPressed: () async {
            // TODO: Navigator.Push a package editor route
            //await Navigator.push(context, new MaterialPageRoute());
          },
        )
      ],
    ));
    return lines;
  }

  @override
  Widget build(BuildContext build){
    return new Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: new Card(
        child: new Column(
          children: _getLines()
          // TODO: Buttons!
        ),
      ),
    );
  }
}