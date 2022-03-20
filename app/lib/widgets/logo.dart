import 'dart:math' as math;

import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 100),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              child: Transform.rotate(
                angle: -math.pi / 4,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color(0xff00227E),
                  ),
                ),
              ),
            ),
            Positioned(
              child: Transform.rotate(
                angle: -math.pi / 8,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color(0xff01589c),
                  ),
                ),
              ),
            ),
            Positioned(
              child: Transform.rotate(
                angle: 0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color(0xff008edb),
                  ),
                ),
              ),
            ),
            Positioned(
              child: Transform.rotate(
                angle: math.pi / 8,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color(0xff3aa8e3),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12.5,
              left: 12.5,
              child: Container(
                width: 75,
                height: 75,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffcfe2ff),
                ),
              ),
            ),
          ],
        ));
  }
}
