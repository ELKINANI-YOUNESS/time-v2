import 'package:flutter/material.dart';
import 'main1.dart';

class CustomerListPage extends StatelessWidget {
  final List<Customer> customers;

  CustomerListPage(this.customers);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer List'),
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return ListTile(
            title: Text(customer.name),
            subtitle: Text(customer.description),
            onTap: () {
              // Navigate to a detailed view of the customer if needed
            },
          );
        },
      ),
    );
  }
}
