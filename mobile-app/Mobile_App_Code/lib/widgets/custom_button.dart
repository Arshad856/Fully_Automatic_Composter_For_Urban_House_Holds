import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onPressed; // Allow async or void
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed, // Make it nullable
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 295,
      height: 68,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D986A), Color(0xFF0B8A5F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(19.53),
        boxShadow: [
          BoxShadow(
            color: const Color(0x804F7569),
            offset: const Offset(0, 8.55),
            blurRadius: 29.3,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(19.53),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 19.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
