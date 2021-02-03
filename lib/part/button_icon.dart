import 'package:flutter/material.dart';



class ButtonWithIcon extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final String label;
  final color;

  ButtonWithIcon({this.onPressed, this.icon, this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: RaisedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: Text(label, style: TextStyle(fontSize:18 ),),
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8),)
            ),
        ),
      ),
    );
  }
}
