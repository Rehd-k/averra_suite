import 'package:flutter/material.dart';
import '../../helpers/financial_string_formart.dart';

Widget buildNameInput(selectedName, nameController, fetchNames,
    selectUserFromSugestion, deselectUserFromSugestion, onchange) {
  return selectedName == null
      ? Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      onchange();
                    },
                  ),
                ),
              ],
            ),
            if (nameController.text.isNotEmpty)
              FutureBuilder<List<Map>>(
                future: fetchNames(nameController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('No suggestions'),
                    );
                  } else {
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.map((suggestion) {
                        return ListTile(
                          title: Text(suggestion['name']),
                          subtitle: Text(suggestion['phone_number']),
                          trailing: Text(suggestion['total_spent']
                              .toString()
                              .formatToFinancial(isMoneySymbol: true)),
                          onTap: () {
                            selectUserFromSugestion(suggestion);
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              ),
          ],
        )
      : Chip(
          label: Text(selectedName?['name']),
          deleteIcon: Icon(Icons.close),
          onDeleted: () {
            deselectUserFromSugestion();
          },
        );
}
