// main.dart
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(PoliticalCoalitionApp());
}

class PoliticalCoalitionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Political Coalition Calculator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.latoTextTheme(), // Set the app-wide font
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CoalitionCalculator(),
    );
  }
}

class Party {
  final String name;
  final int seats;
  Party({required this.name, required this.seats});
}

class CoalitionCalculator extends StatefulWidget {
  @override
  _CoalitionCalculatorState createState() => _CoalitionCalculatorState();
}

class _CoalitionCalculatorState extends State<CoalitionCalculator> {
  final _partyNameController = TextEditingController();
  final _partySeatsController = TextEditingController();
  final List<Party> _parties = [];
  final int _targetSeats = 121;
  final int _totalParliamentSeats = 240;
  int _totalSeatsEntered = 0;
  List<List<Party>> _coalitions = [];

  void _addParty() {
    final name = _partyNameController.text;
    final seats = int.tryParse(_partySeatsController.text);
    if (name.isEmpty || seats == null || seats < 1) return;

    setState(() {
      _parties.add(Party(name: name, seats: seats));
      _totalSeatsEntered += seats;
    });

    _partyNameController.clear();
    _partySeatsController.clear();
  }

  void _calculateCoalitions() {
    _coalitions.clear();
    List<Party> currentCoalition = [];
    _findCoalitions(0, 0, currentCoalition);
  }

  void _findCoalitions(int index, int currentSeats, List<Party> currentCoalition) {
    if (currentSeats >= _targetSeats) {
      setState(() {
        _coalitions.add(List.from(currentCoalition));
      });
      return;
    }
    if (index >= _parties.length) return;

    currentCoalition.add(_parties[index]);
    _findCoalitions(index + 1, currentSeats + _parties[index].seats, currentCoalition);

    currentCoalition.removeLast();
    _findCoalitions(index + 1, currentSeats, currentCoalition);
  }

  void _exportCoalitions() {
    final textContent = StringBuffer();
    final htmlContent = StringBuffer();
    htmlContent.write("<!DOCTYPE html><html><head><title>Coalitions</title></head><body><h1>Possible Coalitions</h1>");

    for (final coalition in _coalitions) {
      final coalitionText = coalition.map((p) => p.name).join(" ");
      final totalSeats = coalition.fold(0, (sum, p) => sum + p.seats);

      textContent.writeln("Coalition: $coalitionText - Total seats: $totalSeats");
      htmlContent.write("<div style='border:1px solid #000; padding:10px; margin:10px;'><strong>Coalition: </strong>");

      for (final party in coalition) {
        htmlContent.write("<span style='padding:5px; background-color:#4CAF50; color:white; margin-right:5px;'>${party.name}</span>");
      }
      htmlContent.write("<br><strong>Total seats:</strong> $totalSeats</div>");
    }

    htmlContent.write("</body></html>");

    _downloadFile('coalitions.txt', textContent.toString());
    _downloadFile('coalitions.html', htmlContent.toString(), isHtml: true);
  }

  void _downloadFile(String fileName, String content, {bool isHtml = false}) {
    final bytes = html.Blob([content], isHtml ? 'text/html' : 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(bytes);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Political Coalition Calculator'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _partyNameController,
              decoration: InputDecoration(
                labelText: 'Party Name',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.green.shade50,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _partySeatsController,
              decoration: InputDecoration(
                labelText: 'Seats Won',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.green.shade50,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _addParty,
                  child: Text('Add Party'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                ),
                ElevatedButton(
                  onPressed: _totalSeatsEntered == _totalParliamentSeats ? _calculateCoalitions : null,
                  child: Text('Calculate Coalitions'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                ),
                ElevatedButton(
                  onPressed: _coalitions.isNotEmpty ? _exportCoalitions : null,
                  child: Text('Export Coalitions'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Total Seats Entered: $_totalSeatsEntered/$_totalParliamentSeats',
              style: TextStyle(fontSize: 16, color: Colors.green.shade700),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _coalitions.length,
                itemBuilder: (context, index) {
                  final coalition = _coalitions[index];
                  final coalitionText = coalition.map((p) => p.name).join(" ");
                  final totalSeats = coalition.fold(0, (sum, p) => sum + p.seats);

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text("Coalition: $coalitionText"),
                      subtitle: Text("Total seats: $totalSeats"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
