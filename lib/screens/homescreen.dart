import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dreamproject/dbhelper.dart';
import 'package:intl/intl.dart';


class homescreen extends StatefulWidget {

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  double money = 0.0;
  String day=DateFormat('yMd').format(DateTime.now());
  @override
  void initState() {
    super.initState();
  }

void setdata(String tt,String cost,String date) async{
    double amount=double.parse(cost);
  await DatabaseHelper.instance.insertExpense(
    Expense(title: tt, amount: amount, date: date),
  );
  setState(() {

  });
}
  Future<void> deleteExpense(int expenseId) async {
    final dbHelper = DatabaseHelper.instance;
    final rowsDeleted = await dbHelper.deleteExpense(expenseId);
    if (rowsDeleted > 0) {
      setState(() {
      });
    } else {
      print('Failed to delete the expense.');
    }
  }
  void showConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                deleteExpense(id); // Call the deleteExpense function
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getmoney(String day) async{
    double? totalSpent = await DatabaseHelper.instance.getTotalMoneySpent(day);
    setState(() {
      if(totalSpent!=null) money=totalSpent;
      else money=0.0;
    });
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );

    if (pickedDate != null) {
      setState(() {
        day = DateFormat('yMd').format(pickedDate);
        getmoney(day);
      });
    }
  }

  @override
  String currday = DateFormat('yMd').format(DateTime.now());
  Scaffold build(BuildContext context) {
    getmoney(day);
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightBlueAccent,
          child: Icon(Icons.add),
          onPressed: () {
            String expense='',price='0.0';
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => SingleChildScrollView(
                    child:Container(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        color: Color(0xff757575),
                        child: Container(
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                'Add Expense',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                              TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Expense'
                                ),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.characters,
                                onChanged: (value) {
                                  expense=value;
                                },
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Price'
                                ),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  price=value;
                                },
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 120.0),
                                child: MaterialButton(
                                  textColor: Colors.white,
                                  color: Colors.black,
                                  child: Text(
                                    'Add',
                                  ),
                                  onPressed: () {
                                    String formatter = DateFormat('yMd').format(DateTime.now());
                                    setdata(expense,price,formatter);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                )
            );
          }
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                top: 60.0, left: 30.0, right: 30.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expenses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: CircleAvatar(
                        child: Icon(
                          Icons.list,
                          size: 30.0,
                          color: Colors.lightBlueAccent,
                        ),
                        backgroundColor: Colors.white,
                        radius: 25.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Today : $money rs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  Text('List of Expenses :',style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Expense>>(
                      future: DatabaseHelper.instance.getExpensesByDate(day),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final expenses = snapshot.data!;
                          return ListView.builder(
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              final id=expenses[index].id;
                              return ListTile(
                                title: Text(expense.title),
                                subtitle: Text('Amount: ${expense.amount}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => showConfirmationDialog(context, id!),
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

