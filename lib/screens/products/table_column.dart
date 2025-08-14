// Define columns using the provided structure
final List<Map<String, dynamic>> columnDefinitionMaps = [
  {'name': 'Title', 'sortable': true, 'type': 'text', 'field': 'title'},
  {'name': 'Category', 'sortable': true, 'type': 'text', 'field': 'category'},
  {'name': 'Price', 'sortable': true, 'type': 'money', 'field': 'price'},
  {'name': 'ROQ', 'sortable': false, 'type': 'number', 'field': 'roq'},
  {'name': 'Quantity', 'sortable': true, 'type': 'number', 'field': 'quantity'},
  {
    'name': 'Description',
    'sortable': false,
    'type': 'text',
    'field': 'description'
  },
  {'name': 'Brand', 'sortable': false, 'type': 'text', 'field': 'brand'},
  {'name': 'Weight', 'sortable': false, 'type': 'number', 'field': 'weight'},
  {'name': 'Unit', 'sortable': false, 'type': 'string', 'field': 'unit'},
  {
    'name': 'Available',
    'sortable': false,
    'type': 'string',
    'field': 'isAvailable'
  },
  {
    'name': 'Initiator',
    'sortable': false,
    'type': 'string',
    'field': 'initiator'
  },
  {
    'name': 'Added On',
    'sortable': true,
    'type': 'date',
    'field': 'createdAt'
  }, // Made sortable for demo
  {
    'name': 'Actions',
    'sortable': false,
    'type': 'string',
    'field': ''
  } // Empty field for actions
];

// Define columns using the provided structure
final List<Map<String, dynamic>> dropDownMaps = [
  {'name': 'Title', 'field': 'title'},
  {'name': 'Category', 'field': 'category'},
  {'name': 'Price', 'field': 'price'},
  {'name': 'ROQ', 'field': 'roq'},
  {'name': 'Quantity', 'field': 'quantity'},
  {'name': 'SKU', 'field': 'barcode'},
  {'name': 'Description', 'field': 'description'},
  {'name': 'Brand', 'field': 'brand'},
  {'name': 'Weight', 'field': 'weight'},
  {'name': 'Unit', 'field': 'unit'} // Empty field for actions
];
