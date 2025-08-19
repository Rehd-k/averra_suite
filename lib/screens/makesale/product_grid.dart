import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../helpers/financial_string_formart.dart';
import 'product_service.dart';

class ProductGrid extends StatelessWidget {
  final bool smallScreen;
  final Function(Product) addToCart;
  final PagingController pagingController;

  const ProductGrid({
    super.key,
    required this.smallScreen,
    required this.addToCart,
    required this.pagingController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8.0, top: 2, bottom: 8),
            child: RefreshIndicator(
                onRefresh: () => Future.sync(
                      () => pagingController.refresh(),
                    ),
                child: PagingListener(
                  controller: pagingController,
                  builder: (context, state, fetchNextPage) => PagedGridView(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 100 / 150,
                      crossAxisCount: smallScreen ? 2 : 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, res, index) =>
                          productItem(res, context, index),
                      noMoreItemsIndicatorBuilder: (context) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('You have reached the end'),
                        ),
                      ),
                    ),
                  ),
                ))));
  }

  Material productItem(res, BuildContext context, index) {
    return Material(
      color: (res.quantity == 0)
          ? Colors.red
          : (index % 2 == 0)
              ? Colors.green
              : (index % 5 == 0)
                  ? Colors.yellow
                  : Colors.pink,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          addToCart(res);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Tooltip(
                message: res.title.toString(),
                child: Text(
                  res.title.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                res.quantity.toString().formatToFinancial(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                res.price.toString().formatToFinancial(isMoneySymbol: true),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
