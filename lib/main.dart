// main.dart

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const CalculadoraApp());

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculadora(),
    );
  }
}

class Calculadora extends StatefulWidget {
  const Calculadora({Key? key}) : super(key: key);

  @override
  CalculadoraScreenState createState() => CalculadoraScreenState();
}

class CalculadoraScreenState extends State<Calculadora> {
  dynamic displaytxt = '0';
  String operand = '';
  double firstNum = 0;
  bool isNewInput = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Calculadora'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text('$displaytxt',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 40)),
                  )
                ],
              ),
            ),
            Align(
              // Utiliza Align para alinear la columna en la parte inferior
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .end, // Puedes ajustar según tus preferencias
                children: <Widget>[
                  for (var row in [
                    ['AC', '+/-', '%', '/'],
                    ['7', '8', '9', 'x'],
                    ['4', '5', '6', '-'],
                    ['1', '2', '3', '+'],
                    ['0', '.', '=', '⌫']
                  ])
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Puedes ajustar según tus preferencias
                      children: row.map((btn) => calcButton(btn)).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget calcButton(String buttonText) {
    return Padding(
      padding: const EdgeInsets.all(10), // Ajusta el espacio entre los botones
      child: ElevatedButton(
        onPressed: () => onButtonPress(buttonText),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Ajusta el radio aquí
          ),
          padding: const EdgeInsets.all(
            39,
          ), // Ajusta el espaciado interno de los botones
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ), // Ajusta el tamaño del texto si es necesario
        ),
      ),
    );
  }

  void onButtonPress(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        clearAll();
      } else if (buttonText == '+/-' || buttonText == '%') {
        handleUnaryOperation(buttonText);
      } else if (buttonText == '.') {
        handleDecimal();
      } else if (buttonText == '=') {
        calculateResult();
      } else if (buttonText == '⌫') {
        handleBackspace();
      } else {
        handleDigitOrOperator(buttonText);
      }
    });
  }

  void handleBackspace() {
    setState(() {
      if (displaytxt.length > 1) {
        // Elimina el último carácter
        displaytxt = displaytxt.substring(0, displaytxt.length - 1);
      } else {
        // Si solo hay un carácter, establece el texto en '0'
        displaytxt = '0';
        isNewInput = true;
      }
    });
  }

  void clearAll() {
    displaytxt = '0';
    operand = '';
    firstNum = 0;
    isNewInput = true;
  }

  void handleUnaryOperation(String operation) {
    double num = double.parse(displaytxt.toString());
    switch (operation) {
      case '+/-':
        displaytxt = (-num).toString();
        break;
      case '%':
        displaytxt = (num / 100).toString();
        break;
    }
  }

  void handleDecimal() {
    if (!displaytxt.toString().contains('.')) {
      displaytxt = '$displaytxt.';
    }
  }

  void handleDigitOrOperator(String input) {
    if (isNewInput) {
      displaytxt = input;
      isNewInput = false;
    } else {
      displaytxt = '$displaytxt$input';
    }
  }

  void calculateResult() {
    String expression = displaytxt;
    expression = expression.replaceAll('x', '*'); // Reemplaza 'x' con '*'

    Parser p = Parser();
    Expression exp = p.parse(expression);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);

    String result;
    if (eval % 1 == 0) {
      // Si el resultado es un número entero, mostrarlo sin decimales
      result = eval.toInt().toString();
    } else {
      // Si el resultado tiene decimales, mostrarlo con dos decimales
      result = eval.toStringAsFixed(2);
    }

    setState(() {
      displaytxt = result;
      isNewInput = true;
    });
  }
}
