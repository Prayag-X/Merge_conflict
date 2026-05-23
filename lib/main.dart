import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String output = "0";
  double firstNumber = 0;
  String operator = "";

  void buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        output = "0";
        firstNumber = 0;
        operator = "";
      } else if (value == "+" ||
          value == "-" ||
          value == "×" ||
          value == "÷") {
        firstNumber = double.parse(output);
        operator = value;
        output = "0";
      } else if (value == "=") {
        double secondNumber = double.parse(output);
        double result = 0;

        if (operator == "+") {
          result = firstNumber + secondNumber;
        } else if (operator == "-") {
          result = firstNumber - secondNumber;
        } else if (operator == "×") {
          result = firstNumber * secondNumber;
        } else if (operator == "÷") {
          result = firstNumber / secondNumber;
        }

        output = result.toString();
      } else {
        if (output == "0") {
          output = value;
        } else {
          output += value;
        }
      }
    });
  }

  Widget buildButton(String text, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(22),
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          onPressed: () => buttonPressed(text),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                output,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Row(
            children: [
              buildButton("7", Colors.grey),
              buildButton("8", Colors.grey),
              buildButton("9", Colors.grey),
              buildButton("÷", Colors.orange),
            ],
          ),

          Row(
            children: [
              buildButton("4", Colors.grey),
              buildButton("5", Colors.grey),
              buildButton("6", Colors.grey),
              buildButton("×", Colors.orange),
            ],
          ),

          Row(
            children: [
              buildButton("1", Colors.grey),
              buildButton("2", Colors.grey),
              buildButton("3", Colors.grey),
              buildButton("-", Colors.orange),
            ],
          ),

          Row(
            children: [
              buildButton("C", Colors.red),
              buildButton("0", Colors.grey),
              buildButton("=", Colors.green),
              buildButton("+", Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
}