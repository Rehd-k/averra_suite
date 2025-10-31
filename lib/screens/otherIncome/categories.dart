import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/components/emptylist.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';

final Map<String, IconData> hospitalityIcons = {
  "hotel": Icons.hotel,
  "restaurant": Icons.restaurant,
  "local_bar": Icons.local_bar,
  "coffee": Icons.local_cafe,
  "room_service": Icons.room_service,
  "event": Icons.event,
  "meeting_room": Icons.meeting_room,
  "store": Icons.store,
  "shopping_bag": Icons.shopping_bag,
  "receipt": Icons.receipt_long,
  "credit_card": Icons.credit_card,
  "attach_money": Icons.attach_money,
  "point_of_sale": Icons.point_of_sale,
  "business_center": Icons.business_center,
  "work": Icons.work,
  "support": Icons.support_agent,
  "call": Icons.call,
  "email": Icons.email,
  "wifi": Icons.wifi,
  "local_taxi": Icons.local_taxi,
};

@RoutePage()
class OtherIncomeCategoriesScreen extends StatefulWidget {
  const OtherIncomeCategoriesScreen({super.key});

  @override
  OtherIncomeCategoriesState createState() => OtherIncomeCategoriesState();
}

class OtherIncomeCategoriesState extends State<OtherIncomeCategoriesScreen> {
  String? selectedIconName;
  TextEditingController newCategory = TextEditingController();
  ApiService apiService = ApiService();
  late List categories = [];

  void selectIcon(icon) {
    setState(() {
      selectedIconName = icon;
    });
  }

  Future<void> handleUpdate(id, update) async {
    await apiService.patch('otherIncome/category/update/$id', update);
    getCategories();
  }

  Future<void> handleDelete(id) async {
    await apiService.delete('otherIncome/category/delete/$id');
    getCategories();
  }

  Future<void> createCategory() async {
    var newCat = {'icon': selectedIconName, 'title': newCategory.text};
    await apiService.post('otherIncome/category', newCat);
    setState(() {
      selectedIconName = 'hotel';
      newCategory.clear();
    });
    getCategories();
  }

  Future<void> getCategories() async {
    var result = await apiService.get('otherIncome/category');
    setState(() {
      categories = result.data;
    });
  }

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  @override
  void dispose() {
    newCategory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "OtherIncomes Categories",
                  style: TextStyle(fontSize: smallScreen ? 10 : 14),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: EdgeInsets.symmetric(
                      horizontal: smallScreen ? 10 : 16,
                      vertical: smallScreen ? 5 : 10,
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    _showAddCategorySheet(
                      context,
                      selectedIconName,
                      createCategory,
                      newCategory,
                      selectIcon,
                    );
                  },
                  icon: const Icon(Icons.add, size: 10),
                  label: const Text(
                    "Add Category",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: categories.isEmpty
                  ? EmptyComponent(
                      icon: Icons.category_outlined,
                      message: "No Categores Yet",
                      reload: getCategories,
                      subMessage: 'Add Categories to Start Logging OtherIncomes',
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 60,
                        ), // Add padding for pagination
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Determine how many cards per row based on screen width
                            double maxWidth = constraints.maxWidth;
                            int cardsPerRow;

                            if (maxWidth >= 900) {
                              cardsPerRow = 3; // large screen
                            } else if (maxWidth >= 600) {
                              cardsPerRow = 2; // medium screen
                            } else {
                              cardsPerRow = 1; // small screen
                            }

                            // Card width calculation with spacing
                            double spacing = 16.0;
                            double cardWidth =
                                (maxWidth - (spacing * (cardsPerRow - 1))) /
                                cardsPerRow;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: categories
                                  .map(
                                    (res) => SizedBox(
                                      width: cardWidth,
                                      child: CategoryCard(
                                        title: '${res['title']}',
                                        id: res['_id'],
                                        handleUpdate: handleUpdate,
                                        icon:
                                            hospitalityIcons['${res['icon']}'] ??
                                            Icons.help_outline,
                                        handleDelete: handleDelete,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  final String title;
  final String id;
  final IconData icon;
  final Function handleUpdate;
  final Function handleDelete;
  final Color? color;

  const CategoryCard({
    super.key,
    required this.title,
    required this.id,
    required this.icon,
    required this.handleUpdate,
    required this.handleDelete,
    this.color,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        child: Card(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: widget.color?.withAlpha(200),
                      child: Icon(widget.icon, color: widget.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Hover actions
              if (_hovering)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Row(
                    children: [
                      _ActionButton(
                        icon: Icons.edit,
                        color: Colors.grey[600]!,
                        onTap: () {
                          _showEditCategorySheet(
                            context,
                            widget.title,
                            widget.id,
                            widget.handleUpdate,
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      _ActionButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        onTap: () {
                          _showDeleteConfirmation(
                            context,
                            widget.title,
                            widget.id,
                            widget.handleDelete,
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

void _showEditCategorySheet(
  BuildContext context,
  String categoryName,
  String id,
  handleUpdate,
) {
  final controller = TextEditingController(text: categoryName);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Edit Category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Category Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                handleUpdate(id, {'title': controller.text});
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      );
    },
  );
}

void _showDeleteConfirmation(
  BuildContext context,
  String categoryName,
  String id,
  Function handleDelete,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Delete Category"),
        content: Text("Are you sure you want to delete \"$categoryName\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              handleDelete(id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );
}

void _showAddCategorySheet(
  BuildContext context,
  selectedIconName,
  createCategory,
  newCategory,
  selectIcon,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add Category",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Category name input
                TextField(
                  controller: newCategory,
                  decoration: const InputDecoration(
                    labelText: "Category Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon picker grid
                Expanded(
                  child: SingleChildScrollView(
                    child: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // disable inner scroll
                      children: hospitalityIcons.entries.map((entry) {
                        final isSelected = selectedIconName == entry.key;
                        return GestureDetector(
                          onTap: () {
                            selectIcon(entry.key);
                            setState(() {
                              selectedIconName = entry.key;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(150)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Icon(
                              entry.value,
                              size: 32,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    if (newCategory.text.isEmpty && selectedIconName.isEmpty) {
                      return;
                    }
                    createCategory();
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      );
    },
  );
}
