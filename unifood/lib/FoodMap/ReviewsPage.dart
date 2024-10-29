import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'ReviewFormPage.dart';
import 'RatingAndReviews.dart';
import 'package:unifood/DemoLocalizations.dart';

class ReviewsPage extends StatefulWidget {
  final String title;
  final String address;

  const ReviewsPage({super.key, required this.title, required this.address});

  @override
  State<StatefulWidget> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late Stream<QuerySnapshot> _reviewsStream;
  int? _selectedRating;
  Map<int, int> _ratingFrequency = {};

  @override
  void initState() {
    // Connects to the firebase database
    super.initState();
    _reviewsStream = FirebaseFirestore.instance
        .collection(widget.title)
        .doc(widget.address)
        .collection('reviews')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('${widget.title} ${DemoLocalizations.of(context).reviews}'),
        ),
        // Allows user to filter reviews based on rating
        actions: <Widget>[
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedRating = value == 0 ? null : value;
              });
            },
            itemBuilder: (BuildContext context) {
              return [0, 1, 2, 3, 4, 5].map((rating) {
                return PopupMenuItem<int>(
                  value: rating,
                  child: Text(rating == 0 ? DemoLocalizations.of(context).all : '\$' * rating),
                );
              }).toList();
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Color.fromARGB(120, 9, 97, 25)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft
              )
          ),
        ),
      ),
      // Shows all the reviews of the specific store found in the firebase
      body: StreamBuilder<QuerySnapshot>(
        stream: _reviewsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(DemoLocalizations.of(context).somErr);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(DemoLocalizations.of(context).loading);
          }

          _ratingFrequency.clear();
          for (var document in snapshot.data!.docs) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            _ratingFrequency[data['rating']] = (_ratingFrequency[data['rating']] ?? 0) + 1;
          }

          return ListView(
            children: snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              if (_selectedRating != null && data['rating'] != _selectedRating) {
                return Container(); // Return an empty container for reviews that don't match the filter
              }
              return Card(
                child: ListTile(
                  title: Text('${DemoLocalizations.of(context).rating}: ${'\$' * data['rating']}'),
                  subtitle: Text(data['comment']),
                ),
              );
            }).toList()..insert(0, _selectedRating == null ? _buildDataTableAndChart() : Container()),
          );
        },
      ),
      // Allows users to add a new review
      floatingActionButton: FloatingActionButton(
        onPressed: _addReview,
        tooltip: DemoLocalizations.of(context).addReview,
        child: const Icon(Icons.add),
      ),
    );
  }
  // Widget for showing data table and bar chart
  // Shows the number of each rating in table and graph form
  Widget _buildDataTableAndChart() {
    List<RatingData> data = _ratingFrequency.entries
        .map((entry) => RatingData(entry.key, entry.value))
        .toList();

    // Sorts the data in decreasing order based on the rating
    data.sort((a, b) => b.rating.compareTo(a.rating));

    List<BarChartGroupData> chartData = data.map((e) => BarChartGroupData(
      x: e.rating,
      barRods: [
        BarChartRodData(
          toY: e.frequency.toDouble(),
          color: Colors.green,
        ),
      ],
    )).toList();

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DataTable(
              columnSpacing: 10,
              columns: <DataColumn>[
                DataColumn(
                  label: Text(
                    DemoLocalizations.of(context).rating,
                  ),
                ),
                DataColumn(
                  label: Text(
                    DemoLocalizations.of(context).frequency,
                  ),
                ),
              ],
              rows: data.map((RatingData ratingData) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Center(child: Text(ratingData.rating.toString()))), // Center the text
                    DataCell(Center(child: Text(ratingData.frequency.toString()))), // Center the text
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BarChart(
                BarChartData(
                  barGroups: chartData,
                  barTouchData: BarTouchData(
                    enabled: false,
                  ),
                  // Axis titles
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(
                      axisNameWidget: Text(DemoLocalizations.of(context).frequency),
                    ),
                    topTitles: AxisTitles(
                      axisNameWidget: Text(DemoLocalizations.of(context).rating),
                    ),
                  ),
                  gridData: const FlGridData(
                    show: false,
                  ),
                ),
                swapAnimationDuration: const Duration(milliseconds: 150),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addReview() {
    // Navigates to the review form page
    // If no errors then review is added to firebase and review page
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReviewFormPage(
              title: widget.title,
              address: widget.address,
            )
        )
    ).then((newReview) async {
      if (newReview != null) {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection(widget.title)
            .doc(widget.address)
            .collection('reviews')
            .add(newReview.toMap());
        // Shows a snackbar when the review is added to the firebase
        // Gives the user the option to undo their review
        // Will remove the review from the firebase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(DemoLocalizations.of(context).revPosted),
            action: SnackBarAction(
              label: DemoLocalizations.of(context).undo,
              onPressed: () {
                docRef.delete();
              },
            ),
          ),
        );
      }
    });
  }
}