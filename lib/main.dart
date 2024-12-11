import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; // Matematik ifodalar uchun kutubxona

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Calculator(),
      theme: ThemeData.dark(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String input = '';
  String result = '0';

  void buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '0';
      } else if (value == '←') {
        input = input.isNotEmpty ? input.substring(0, input.length - 1) : '';
      } else if (value == '=') {
        try {
          result = (evaluateExpression(input)).toString();
        } catch (e) {
          result = 'Error';
        }
      } else if (value == 'EE') {
        // Agar oxirgi belgi operator bo'lmasa, 'e' qo'shish
        if (input.isNotEmpty && !_endsWithOperator(input)) {
          input += 'e'; // 'EE' matematik ifoda ichida `e` sifatida ishlatiladi
        }
      } else if (value == '0') {
        // Ketma-ket 0 ni cheklash
        if (input.isEmpty || _endsWithOperator(input)) {
          input += '0';
        } else if (!input.endsWith('0') || input.contains('.')) {
          input += '0';
        }
      } else {
        input += value;
      }
    });
  }

  bool _endsWithOperator(String input) {
    if (input.isEmpty) return false;
    String lastChar = input.substring(input.length - 1); // Oxirgi belgini olish
    return '+-×÷e('.contains(lastChar); // Belgilar qatorini tekshirish
  }

  double evaluateExpression(String input) {
    try {
      // Ilmiy notatsiyani to‘g‘ri ishlatish uchun '×' va '÷' ni almashtirish
      String formattedInput = input
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('e', '*10^'); // `e` ni `*10^` formatiga aylantirish

      final parser = Parser();
      final expression = parser.parse(formattedInput);
      final contextModel = ContextModel();
      final result = expression.evaluate(EvaluationType.REAL, contextModel);

      return result;
    } catch (e) {
      return double.nan; // Xato holatida NaN qaytarish
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Matematik ifoda maydoni
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: Text(
              input,
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
          // Natija maydoni
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            alignment: Alignment.centerRight,
            child: Text(
              result,
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 50,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  buildSpecialRow(['C', '←', '(', ')', '÷']),
                  buildButtonRow(['7', '8', '9', '×']),
                  buildButtonRow(['4', '5', '6', '+']),
                  buildButtonRow(['1', '2', '3', '-']),
                  buildButtonRow(['0', '.', 'EE', '=']),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildButtonRow(List<String> values) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: values.map((value) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: value == '='
                      ? const Color.fromARGB(255, 28, 14, 19)
                      : Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () => buttonPressed(value),
                child: Text(
                  value,
                  style: TextStyle(
                    color: value == 'C'
                        ? const Color.fromARGB(255, 106, 201, 245)
                        : (value == '=' ||
                                value == 'EE' ||
                                value == "×" ||
                                value == "+" ||
                                value == "-")
                            ? Colors.greenAccent
                            : Colors.pinkAccent,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildSpecialRow(List<String> values) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: values.map((value) {
          bool isSmallButton = value == '(' || value == ')';
          return Expanded(
            flex: isSmallButton ? 1 : 2,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () => buttonPressed(value),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
