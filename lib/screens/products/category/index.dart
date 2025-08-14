import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'add_category.dart';
import 'view_category.dart';

@RoutePage()
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryIndexState createState() => CategoryIndexState();
}

class CategoryIndexState extends State<CategoryScreen> {
  final GlobalKey<ViewCategoryState> _viewProductKey =
      GlobalKey<ViewCategoryState>();

  void updateCategories() {
    _viewProductKey.currentState?.updateCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          smallScreen
              ? SizedBox.shrink()
              : Expanded(
                  flex: 1,
                  child: AddCategory(updateCategory: updateCategories),
                ),
          SizedBox(width: smallScreen ? 0 : 20),
          Expanded(
            flex: 2,
            child: ViewCategory(
              key: _viewProductKey,
              updateCategory: updateCategories,
            ),
          ),
        ],
      ),
    );
  }
}
