import 'package:flutter/material.dart';
import 'package:telehealth_app/globals.dart';

class BannerModel {
  String text;
  List<Color> cardBackground;
  String image;

  BannerModel(this.text, this.cardBackground, this.image);
}

List<BannerModel> bannerCards = [
  BannerModel(
      isDoctor || isNurse
          ?"Cyber Training"
      :"Chats",
      [
        const Color(0xff7ae36b),
        const Color(0xff248704),
      ],
      "assets/414-bg.png"),
  BannerModel(
      isDoctor
          ?"Add Medical Record"
          :"View Medical Record",
      [
        const Color(0xff7ae36b),
        const Color(0xff248704),
      ],
      "assets/covid-bg.png"),
];
