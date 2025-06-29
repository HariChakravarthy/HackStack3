import 'package:flutter/material.dart';

class HariSquaretitle extends StatelessWidget {
  final String imagePath;
  final Function()? onTap; // initialising the parameters of the function created
  const HariSquaretitle({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: Image.asset(
        imagePath,
        height: 50 ,
      ),
      ),
    );
  }
}
