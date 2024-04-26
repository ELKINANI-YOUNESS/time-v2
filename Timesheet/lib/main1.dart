import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesheet_1/update_time.dart';
import 'customer_list_page.dart';

void main() => runApp(UpdateTime());

class main1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientAdditionPage()),
          );

          // Refresh the customer list after adding a customer
          await _loadCustomers();
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
      body: _buildCustomerList(),
    );
  }

  Widget _buildCustomerList() {
    if (_customers.isEmpty) {
      return Center(child: Text('No customers found'));
    } else {
      return ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return ListTile(
            title: Text(customer.name),
            subtitle: Text(customer.description),
            onTap: () {
              // Navigate to a detailed view of the customer if needed
            },
          );
        },
      );
    }
  }

  Future<void> _loadCustomers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCustomers = prefs.getStringList('customers') ?? [];
    List<Customer> customers = [];

    for (String customerString in savedCustomers) {
      try {
        customers.add(Customer.fromString(customerString));
      } catch (e) {
        print('Error parsing customer: $e');
      }
    }

    setState(() {
      _customers = customers;
    });
  }
}

class Customer {
  final String name;
  final String description;
  final String address;
  final String phone;
  final String fax;
  final String email;

  Customer(this.name, this.description, this.address, this.phone, this.fax, this.email);

  // Factory method to create a Customer object from a string representation
  factory Customer.fromString(String customerString) {
    List<String> parts = customerString.split('|');
    if (parts.length != 6) {
      throw FormatException('Invalid customer string: $customerString');
    }
    return Customer(
      parts[0], // name
      parts[1], // description
      parts[2], // address
      parts[3], // phone
      parts[4], // fax
      parts[5], // email
    );
  }

  // Method to convert Customer object to a string representation
  String toString() {
    return '$name|$description|$address|$phone|$fax|$email';
  }
}

class ClientAdditionPage extends StatefulWidget {
  @override
  _ClientAdditionPageState createState() => _ClientAdditionPageState();
}

class _ClientAdditionPageState extends State<ClientAdditionPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _faxController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  // Function to save customer information in shared preferences
  void _saveCustomer() async {
    String name = _nameController.text;
    String description = _descriptionController.text;
    String address = _addressController.text;
    String phone = _phoneController.text;
    String fax = _faxController.text;
    String email = _emailController.text;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCustomers = prefs.getStringList('customers') ?? [];
    savedCustomers.add(Customer(name, description, address, phone, fax, email).toString());
    await prefs.setStringList('customers', savedCustomers);

    // Clear text fields after saving
    _nameController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _phoneController.clear();
    _faxController.clear();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
             controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _faxController,
              decoration: InputDecoration(labelText: 'Fax'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveCustomer();
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}