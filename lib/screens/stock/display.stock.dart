import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';

import '../../service/api.service.dart';
import 'display.stock.table.dart';

@RoutePage()
class DisplayStockScreen extends StatefulWidget {
  const DisplayStockScreen({super.key});

  @override
  DisplayStockState createState() => DisplayStockState();
}

class DisplayStockState extends State<DisplayStockScreen> {
  ApiService apiService = ApiService();
  List departments = [];
  bool isLoading = true;

  Future<void> handleGetDepartments() async {
    var res = await apiService.get('department');
    setState(() {
      departments = res.data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    handleGetDepartments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine how many cards per row based on screen width
            double maxWidth = constraints.maxWidth;
            int cardsPerRow;

            if (maxWidth >= 900) {
              cardsPerRow = 2; // large screen
            } else if (maxWidth >= 600) {
              cardsPerRow = 2; // medium screen
            } else {
              cardsPerRow = 1; // small screen
            }

            // Card width calculation with spacing
            double spacing = 16.0;
            double cardWidth =
                (maxWidth - (spacing * (cardsPerRow - 1))) / cardsPerRow;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                InfoHolder(cardWidth: cardWidth, departmentName: 'all'),
                if (isLoading) Center(child: CircularProgressIndicator()),
                ...departments.map(
                  (e) => SizedBox(
                    width: cardWidth,
                    child: InfoHolder(
                      cardWidth: cardWidth,
                      departmentName: e['title'],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class InfoHolder extends StatelessWidget {
  const InfoHolder({
    super.key,
    required this.cardWidth,
    required this.departmentName,
  });

  final double cardWidth;
  final String departmentName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      height: 300,
      child: Stack(
        children: [
          // underlying content
          Positioned.fill(child: DisplayStockTable(department: departmentName)),

          // semi-transparent overlay (not fully opaque)
          Positioned.fill(
            child: Card(color: Theme.of(context).cardColor.withAlpha(210)),
          ),

          // centered big button
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 18,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DisplayStockTable(department: departmentName),
                  ),
                );
              },
              child: Text(capitalizeFirstLetter('View $departmentName')),
            ),
          ),
        ],
      ),
    );
  }
}
