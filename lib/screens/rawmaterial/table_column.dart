// Define columns using the provided structure
final List<Map<String, dynamic>> columnRmDefinitionMaps = [
  {'name': 'Title', 'sortable': true, 'type': 'text', 'field': 'title'},
  {'name': 'Category', 'sortable': true, 'type': 'text', 'field': 'category'},
  {'name': 'ROQ', 'sortable': false, 'type': 'number', 'field': 'roq'},
  {'name': 'Quantity', 'sortable': true, 'type': 'number', 'field': 'quantity'},
  {'name': 'Measured In', 'sortable': true, 'type': 'text', 'field': 'unit'},
  {
    'name': 'Quanity Per',
    'sortable': true,
    'type': 'number',
    'field': 'servingSize',
  },
  {
    'name': 'Description',
    'sortable': false,
    'type': 'text',
    'field': 'description',
  },
  {
    'name': 'Initiator',
    'sortable': false,
    'type': 'string',
    'field': 'initiator',
  },
  {
    'name': 'Added On',
    'sortable': true,
    'type': 'date',
    'field': 'createdAt',
  }, // Made sortable for demo
  {
    'name': 'Actions',
    'sortable': false,
    'type': 'string',
    'field': 'rmActions',
  }, // Empty field for actions
];

// Define columns using the provided structure
final List<Map<String, dynamic>> dropRmDownMaps = [
  {'name': 'Title', 'field': 'title'},
  {'name': 'Category', 'field': 'category'},
  {'name': 'ROQ', 'field': 'roq'},
  {'name': 'SKU', 'field': 'barcode'},
];
