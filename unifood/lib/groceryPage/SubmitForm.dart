import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:unifood/DemoLocalizations.dart';
import 'package:unifood/groceryPage/GroceryItem.dart';

const Duration debounceDuration = Duration(milliseconds: 500);
// Class used to input info that will be used to create a listTile in GroceryListPage.

class SubmitForm extends StatefulWidget {
  final GroceryItem? groceryItem;

  SubmitForm({super.key, this.groceryItem});

  @override
  State<SubmitForm> createState() => _SubmitFormState();
}

class _SubmitFormState extends State<SubmitForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _itemName;
  int? _quantity;
  String? _imageLink;
  final quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.groceryItem != null) {
      _itemName = widget.groceryItem!.name ?? '';
      _quantity = widget.groceryItem!.quantity ?? 1;
    }
  }

  // Pops, with info, out of the current page and go back to GroceryListPage which displays the list of groceries.
  void _submitForm() async {
    if (_formKey.currentState!.validate() && _itemName!.isNotEmpty) {
      _formKey.currentState!.save();
      final newItem = GroceryItem(name: _itemName, quantity: _quantity);
      Navigator.of(context).pop(newItem);
    }
  }

  // Form for adding an item to the list and database.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.green.shade50),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Color.fromARGB(120, 9, 97, 25)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft)),
        ),
        title: Text(
          DemoLocalizations
              .of(context)
              .addItem,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  DemoLocalizations
                      .of(context)
                      .itemName,
                  style: const TextStyle(fontSize: 14),
                ),
                _AsyncAutocomplete(
                  onItemSelected: (String selectedItem) {
                    setState(() {
                      _itemName = selectedItem;
                      fetchHighResImage(_itemName!);
                    });
                  },
                ),
                Text(
                  DemoLocalizations
                      .of(context)
                      .quantity,
                  style: const TextStyle(fontSize: 14),
                ),
                TextFormField(
                  controller: quantityController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == '0') {
                      return 'Quantity must be greater than 0';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _quantity = (value == '0') ? 1 : int.parse(value!);
                  },
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: _imageLink != null
                        ? SizedBox(
                      width: 250, // Set your desired width
                      height: 250, // Set your desired height
                      child: Image.network(_imageLink!),
                    )
                        : const CircularProgressIndicator(), // You can use any placeholder widget here
                  ),
                ),
                Center(
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: Image.asset('assets/nutritionix.png',)
                    )
                )
              ],
            ),
          ),
        ),),
      floatingActionButton: Align(
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.green,
        onPressed: () {
          if (_formKey.currentState!.validate() &&
              quantityController.text.isNotEmpty) {
            _quantity = int.parse(quantityController.text);
            _submitForm();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(DemoLocalizations
                    .of(context)
                    .addWarning),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: const Icon(Icons.save, color: Colors.white),
      ),
    ),);
  }

  Future<void> fetchHighResImage(String query) async {
    const post_endpoint =
        'https://trackapi.nutritionix.com/v2/natural/nutrients';
    final request = await http.post(Uri.parse(post_endpoint), headers: {
      'x-app-id': '99b93e3a',
      'x-app-key': '460b0308f41b92a523e25acb3cfc16bf',
    }, body: {
      'query': query
    });

    if (request.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(request.body);
      if (jsonData.containsKey('foods')) {
        final List<dynamic> foods = jsonData['foods'];
        if (foods.isNotEmpty) {
          final Map<String, dynamic> firstFood = foods[0];
          if (firstFood.containsKey('photo')) {
            final Map<String, dynamic> photo = firstFood['photo'];
            if (photo.containsKey('highres')) {
              final String highResImageLink = photo['highres'];
              setState(() {
                _imageLink = highResImageLink;
              });
            }
          }
        }
      }
    }
  }
}

// Class for AutoComplete widget.
class _AsyncAutocomplete extends StatefulWidget {
  final Function(String)? onItemSelected;

  const _AsyncAutocomplete({this.onItemSelected});

  @override
  State<_AsyncAutocomplete> createState() => _AsyncAutocompleteState();
}

class _AsyncAutocompleteState extends State<_AsyncAutocomplete> {
  // The query currently being searched for. If null, there is no pending
  // request.
  String? _currentQuery;

  // The most recent options received from the API.
  late Iterable<String> _lastOptions = <String>[];

  late final _Debounceable<Iterable<String>?, String> _debouncedSearch;

  // Calls the "remote" API to search with the given query. Returns null when
  // the call has been made obsolete.
  Future<Iterable<String>?> _search(String query) async {
    _currentQuery = query;

    final Iterable<String> options = await fetcher(_currentQuery!);

    // If another search happened after this one, throw away these options.
    if (_currentQuery != query) {
      return null;
    }
    _currentQuery = null;

    return options;
  }

  @override
  void initState() {
    super.initState();
    _debouncedSearch = _debounce<Iterable<String>?, String>(_search);
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsMaxHeight: 350,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        final Iterable<String>? options =
        await _debouncedSearch(textEditingValue.text);
        if (options == null) {
          return _lastOptions;
        }
        _lastOptions = options;
        return options;
      },
      onSelected: (String selection) {
        widget.onItemSelected?.call(selection);
      },
    );
  }

  // Fetches for data about a query
  Future fetcher(String string) async {
    final String apiUrl =
        'https://trackapi.nutritionix.com/v2/search/instant/?query=$string';
    const appId = '99b93e3a';
    const apiKey = '460b0308f41b92a523e25acb3cfc16bf';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'x-app-id': appId,
      'x-app-key': apiKey
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> foodList = json.decode(response.body)['common'];
        List<String> foodNames = [];
        for (var food in foodList) {
          String item = food['food_name'];
          foodNames.add(item);
        }
        return foodNames;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error $error');
    }
  }
}

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } catch (error) {
      if (error is _CancelException) {
        return null;
      }
      rethrow;
    }
    return function(parameter);
  };
}

// Auxiliary class for Autocomplete widget
class _DebounceTimer {
  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}
