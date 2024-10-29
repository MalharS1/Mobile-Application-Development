import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'RatingAndReviews.dart';
import 'package:unifood/DemoLocalizations.dart';

class ReviewFormPage extends StatefulWidget {
  final String title;
  final String address;

  const ReviewFormPage({super.key, required this.title, required this.address});

  @override
  State<StatefulWidget> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  // Initial values of the ratings and comments
  double _rating = 0;
  String _comment = '';
  int _currentLength = 0;
  // Allows user to write a new review
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).newReview),
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
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              // User can select their rating by sliding or selecting
              // Can only choose whole number ratings
              padding: const EdgeInsets.all(8.0),
              child: RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.attach_money,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
                updateOnDrag: true,
              ),
            ),
            // Area for user to write their comments about the store
            // Are only limited to 300 characters in length
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: DemoLocalizations.of(context).comment,
                  border: const OutlineInputBorder(),
                ),
                maxLines: null,
                onChanged: (value) {
                  setState(() {
                    _comment = value;
                    _currentLength = value.length;
                  });
                },
              ),
            ),
            // Displays the current length of the comment. Will turn red if the
            // length of the comment is greater than 300 characters
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${DemoLocalizations.of(context).currLen}: $_currentLength/300',
                style: TextStyle(
                  color: _currentLength > 300 ? Colors.red : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      // Allows user to save the review to the firebase
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Shows an Alert Dialog if the comment is longer than 300 characters
          if (_currentLength > 300) {
            showDialog(
              context: context,
              builder: (BuildContext context2) {
                return AlertDialog(
                  title: Text(DemoLocalizations.of(context).error),
                  content: Text(DemoLocalizations.of(context).commTooLong),
                  actions: <Widget>[
                    TextButton(
                      child: Text(DemoLocalizations.of(context).ok),
                      onPressed: () {
                        Navigator.of(context2).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else if (_rating == 0 && _comment.isEmpty) {
            // Shows a different Alert if the rating is 0 and comment is empty
            showDialog(
              context: context,
              builder: (BuildContext context3) {
                return AlertDialog(
                  title: Text(DemoLocalizations.of(context).error),
                  content: Text(DemoLocalizations.of(context).selectRatingComment),
                  actions: <Widget>[
                    TextButton(
                      child: Text(DemoLocalizations.of(context).ok),
                      onPressed: () {
                        Navigator.of(context3).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else if (_rating == 0) {
            // Shows different Alert if no rating is selected. Prompts user to select one
            showDialog(
              context: context,
              builder: (BuildContext context4) {
                return AlertDialog(
                  title: Text(DemoLocalizations.of(context).error),
                  content: Text(DemoLocalizations.of(context).chooseRating),
                  actions: <Widget>[
                    TextButton(
                      child: Text(DemoLocalizations.of(context).ok),
                      onPressed: () {
                        Navigator.of(context4).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else if (_comment.isEmpty) {
            // Shows different Alert if no comment is written. Prompts user to write one
            showDialog(
              context: context,
              builder: (BuildContext context5) {
                return AlertDialog(
                  title: Text(DemoLocalizations.of(context).error),
                  content: Text(DemoLocalizations.of(context).addComment),
                  actions: <Widget>[
                    TextButton(
                      child: Text(DemoLocalizations.of(context).ok),
                      onPressed: () {
                        Navigator.of(context5).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else if (_formKey.currentState!.validate()) {
            // Saves the review in the firebase if no errors
            _formKey.currentState!.save();
            Navigator.pop(context, Review(rating: _rating.toInt(), comment: _comment, title: widget.title, address: widget.address));
          }
        },
        tooltip: DemoLocalizations.of(context).submit,
        child: const Icon(Icons.save),
      ),
    );
  }
}