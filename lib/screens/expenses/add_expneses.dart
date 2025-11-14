import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';

@RoutePage()
class AddExpenseScreen extends StatefulWidget {
  final Map? updateInfo;
  const AddExpenseScreen({super.key, this.updateInfo});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ApiService apiService = ApiService();
  late List categories = [];
  bool loadedCategory = false;
  String _category = '';
  DateTime _selectedDate = DateTime.now();

  Future<void> getCategories() async {
    var result = await apiService.get('expense/category');
    setState(() {
      categories = result.data;
      loadedCategory = true;
    });
  }

  Future<void> createNewExpences() async {
    showToast('loading...', ToastificationType.info);
    var data = {
      "category": _category,
      "description": _notesController.text,
      "amount": int.parse(_amountController.text),
      'date': _selectedDate.toString(),
    };
    if (widget.updateInfo == null) {
      await apiService.post('expense', data);
      await sendNotification(
        ['admin', 'manager'],
        "An expense from ${data['category']} is waiting for you're approval",
        'New Expense Added',
      );
    } else {
      await apiService.patch('expense/${widget.updateInfo?['_id']}', data);
      await sendNotification(
        ['admin', 'manager'],
        "The ${data['category']} expense was updated and waiting for you're approval",
        'Expense Updated',
      );
    }

    showToast('Added', ToastificationType.success);
    clearExpencesForm();
  }

  Future<void> sendNotification(
    List<String> recipient,
    String message,
    String title,
  ) async {
    await apiService.post('notifications', {
      "message": message,
      "recipients": recipient,
      "title": title,
    });
  }

  Future<void> clearExpencesForm() async {
    setState(() {
      _category = '';
      _notesController.clear();
      _amountController.clear();
      _selectedDate = DateTime.now();
    });
  }

  @override
  void initState() {
    getCategories();
    if (widget.updateInfo != null) {
      var update = widget.updateInfo;
      _amountController.text = update!['amount'].toString();
      _notesController.text = update['description'];
      _category = update['category'];
      _selectedDate = DateTime.parse(update['date']);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;

    return Center(
      child: Card(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.updateInfo == null
                      ? "Add New Expense"
                      : "Update Expenses",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.paid_outlined, size: 20),
                    hintText: "0.00",
                    labelText: "Amount",
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Amount';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Amount must be a number';
                    }
                    if (int.parse(value) < 1) {
                      return 'Amount cannot be less than 1';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category + Date in Row
                Row(
                  children: [
                    if (loadedCategory)
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.category_outlined,
                              size: 20,
                            ),
                            labelText: "Category",
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items:
                              [
                                    {'title': ''},
                                    ...categories,
                                  ]
                                  .map(
                                    (res) => DropdownMenuItem<String>(
                                      value: res['title'],
                                      child: Text(
                                        capitalizeFirstLetter(res['title']),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              _category = val!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Select Category';
                            }
                            return null;
                          },
                        ),
                      ),

                    if (!smallScreen) const SizedBox(width: 16),
                    if (!smallScreen)
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                              ),
                              labelText: "Date",
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            child: Text(
                              formatBackendTime(
                                _selectedDate.toIso8601String(),
                              ),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (smallScreen)
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                        ),
                        labelText: "Date",
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      child: Text(
                        formatBackendTime(_selectedDate.toIso8601String()),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Add notes...",
                    labelText: "Notes",
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        if (widget.updateInfo == null) {
                          clearExpencesForm();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        elevation: 3,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          createNewExpences();
                        }
                      },
                      child: Text(
                        widget.updateInfo == null
                            ? "Save Expense"
                            : "Update Expense",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
