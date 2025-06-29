import 'package:flutter/material.dart';

class HariButton extends StatelessWidget {

  final Function()? onTap;
  final String text ;

  const HariButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
      padding: EdgeInsets.all(18),
      // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
          color: Colors.blue[900],
        borderRadius: BorderRadius.circular(10),
      ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
    );
  }
}
