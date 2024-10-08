import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'GroceryItem.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unifood/DemoLocalizations.dart';

class NutritionSummary extends StatefulWidget {
  final List? items;

  const NutritionSummary(this.items, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NutritionSummaryState();
}

class _NutritionSummaryState extends State<NutritionSummary> {
  List items_and_descriptions = [];
  Map<dynamic, dynamic> total_map = {
    'calories': 0.0,
    'fat': 0.0,
    'protein': 0.0,
    'carbs': 0.0,
  };

  int touchedIndex = -1; // Pie chart variable

  int _carrouselIndex = 0;
  final CarouselController _carouselControl = CarouselController();

  NutritionixCaller nutritionixCaller = NutritionixCaller();

  @override
  void initState() {
    super.initState();
    getStuff();

  }

  // Example of items_and_descriptions
  //[{name: pollo (1, calories: 187.0, fat: 11.11, protein: 20.37, carbs: 0.04}, 
  // {name: chicken (1, calories: 187.0, fat: 11.11, protein: 20.37, carbs: 0.04}] 
  void getStuff() async {
    if (widget.items != null) {
      var (a, b) =
      await NutritionixCaller().items_with_their_values(widget.items!);
      setState(() {
        items_and_descriptions = a;
        total_map = b;
      });
      // print(items_and_descriptions.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(DemoLocalizations.of(context).summary,
          style: const TextStyle(color: Colors.white),),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(DemoLocalizations.of(context).summary,
        style: const TextStyle(color: Colors.white),),
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
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _carrouselBuild(context),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: items_and_descriptions.length,
              itemBuilder: (context, index) {
                return _buildListItem(items_and_descriptions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Builds a carrousel of widgets.
  Widget _carrouselBuild(BuildContext context)
  {
    return Column(
      mainAxisSize: MainAxisSize.min
        ,children: [
      Flexible(
        fit: FlexFit.loose,
        child: CarouselSlider(
          items: _buildSummaryAndPie(),
          carouselController: _carouselControl,
          options: CarouselOptions(
              autoPlay: false,
              enlargeCenterPage: true,
              aspectRatio: 1.4,
              onPageChanged: (index, reason) {
                setState(() {
                  _carrouselIndex = index;
                });
              }),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildSummaryAndPie().asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _carouselControl.animateToPage(entry.key),
            child: Container(
              width: 12.0,
              height: 12.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                      .withOpacity(_carrouselIndex == entry.key ? 0.9 : 0.4)),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  // Builds the widget that shows the nutritional values.
  Widget _buildTotalNutrition(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 50, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DemoLocalizations
                .of(context)
                .totalNutrition,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildTotalRow(DemoLocalizations
              .of(context)
              .calories, total_map['calories']),
          _buildTotalRow(DemoLocalizations
              .of(context)
              .fat, total_map['fat']),
          _buildTotalRow(DemoLocalizations
              .of(context)
              .protein, total_map['protein']),
          _buildTotalRow(DemoLocalizations
              .of(context)
              .carbs, total_map['carbs']),
        ],
      ),
    );
  }


  // Function that helps to build the _buildTotalNutrition.
  Widget _buildTotalRow(String nutrient, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Builds the data of each individual item.
  Widget _buildListItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item['name']} - ${item['quantity']} ${DemoLocalizations
                  .of(context)
                  .servings}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildNutrientRow(DemoLocalizations
                .of(context)
                .calories, item['calories']),
            _buildNutrientRow(DemoLocalizations
                .of(context)
                .fat, item['fat']),
            _buildNutrientRow(DemoLocalizations
                .of(context)
                .protein, item['protein']),
            _buildNutrientRow(DemoLocalizations
                .of(context)
                .carbs, item['carbs']),
          ],
        ),
      ),
    );
  }
  // Helps the _buildListItem widget.
  Widget _buildNutrientRow(String nutrient, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Makes a list of widget to input into the Carrousel.
  List<Widget> _buildSummaryAndPie()
  {
    List names = [];
    List calos = [];
    List fats = [];
    List proteins = [];
    List carbs = [];

    for (var food in items_and_descriptions) {
      names.add(food['name']);
      calos.add(food['calories'].toDouble());
      fats.add(food['fat'].toDouble());
      proteins.add(food['protein'].toDouble());
      carbs.add(food['carbs'].toDouble());
    }
    return [
      _buildTotalNutrition(context),
      _buildPie(context, names, calos, DemoLocalizations.of(context).calories),
      _buildPie(context, names, fats, DemoLocalizations.of(context).fat),
      _buildPie(context, names, proteins, DemoLocalizations.of(context).protein),
      _buildPie(context, names, carbs, DemoLocalizations.of(context).carbs)
    ];
  }

  // Builds the pie widget that shows at the carrousel.
  Widget _buildPie(BuildContext context, List names, List values, String macro_name)
  {
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: showingSections(names, values),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(macro_name
                ,
                style: const TextStyle(
                  fontSize: 15.0, // Adjust font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Loads data for each pie chart.
  List<PieChartSectionData> showingSections(List names, List values)
  {
    const fontSize = 16.0;
    const radius = 100.0;
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

    List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple, Colors.yellow, Colors.teal, Colors.blueGrey, Colors.brown];


    return List.generate(names.length, (index) {
      final name_ = names[index];
      final value_ = values[index];
      final color = colors[index % colors.length];
      return PieChartSectionData(
        color: color,
        value: value_,
        title: name_,
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
          shadows: shadows,
        ),
      );
    });
  }
}
// Helper class to Request and parse data from the API.
class NutritionixCaller {
  static final NutritionixCaller _singleton = NutritionixCaller._internal();

  NutritionixCaller._internal();

  factory NutritionixCaller() {
    return _singleton;
  }

  Future<(List, Map)> items_with_their_values(List items) async {
    List<double> macro;
    List items_and_values = [];
    Map<String, double> totalMap = {
      'calories': 0,
      'fat': 0,
      'protein': 0,
      'carbs': 0,
    };
    for (GroceryItem element in items) {
      final body =
          POST_Element(element.name!); // Receive information about the item.
      macro = get_macros(await body, element.quantity!);
      items_and_values.add({
        'name': element.name,
        'quantity': element.quantity,
        'calories': macro[0],
        'fat': macro[1],
        'protein': macro[2],
        'carbs': macro[3]
      });
      totalMap['calories'] = totalMap['calories']! + macro[0];
      totalMap['fat'] = totalMap['fat']! + macro[1];
      totalMap['protein'] = totalMap['protein']! + macro[2];
      totalMap['carbs'] = totalMap['carbs']! + macro[3];
    }
    return (items_and_values, totalMap);
  }

  List<double> get_macros(String info, int servings) {
    List<double> macros = [];
    // 0 : calories
    // 1 : fat
    // 2 : protein
    // 3 : carbohydrates

    final jsonResponse = json.decode(info);
    final jsonParsed = jsonResponse['foods'];

    // EXAMPLE OF jsonParsed
    //[{food_name: ghee, brand_name: null, serving_qty: 1, serving_unit: tbsp,
    // serving_weight_grams: 12.8, nf_calories: 112.13, nf_total_fat: 12.73, nf_saturated_fat: 7.93,
    // nf_cholesterol: 32.77, nf_sodium: 0.26, nf_total_carbohydrate: 0, nf_dietary_fiber: 0,
    // nf_sugars: 0, nf_protein: 0.04, nf_potassium: 0.64, nf_p: 0.38

    for (var element in jsonParsed) {
      double calories = element['nf_calories'] * servings.toDouble();
      double fat = element['nf_total_fat'] * servings.toDouble();
      double protein = element['nf_protein'] * servings.toDouble();
      double carbos = element['nf_total_carbohydrate'] * servings.toDouble();
      macros.add(roundDouble(calories, 2));
      macros.add(roundDouble(fat, 2));
      macros.add(roundDouble(protein, 2));
      macros.add(roundDouble(carbos, 2));
  }
    return macros;
  }


  // Aux function to round numbers.
  double roundDouble(double value, int places) {
    double mod = pow(10.0, places).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }


  Future<String> POST_Element(String item_name) async {
    const appId = '99b93e3a';
    const apiKey = '460b0308f41b92a523e25acb3cfc16bf';
    const post_endpoint =
        'https://trackapi.nutritionix.com/v2/natural/nutrients';
    final request = await http.post(Uri.parse(post_endpoint), headers: {
      'x-app-id': appId,
      'x-app-key': apiKey,
    }, body: {
      'query': item_name
    });

    if (request.statusCode == 200) {
      return request.body;
    } else {
      // print('Error: ${request.statusCode}');
    }
    return 'ERROR';
  }
}
