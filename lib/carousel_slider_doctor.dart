import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telehealth_app/model/banner_model.dart';
import 'package:telehealth_app/screens/doctor/add_medical_record.dart';
import 'package:webview_flutter/webview_flutter.dart'; // Import WebView
import 'loading_widget.dart';

class CarouselsliderDoctor extends StatefulWidget {
  const CarouselsliderDoctor({super.key});

  @override
  State<CarouselsliderDoctor> createState() => _CarouselsliderDoctorState();
}

class _CarouselsliderDoctorState extends State<CarouselsliderDoctor> {
  bool isLoading = true;
  final _key = UniqueKey();
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {

      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {},
            onPageStarted: (String url) {},
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse('https://telehealth-app-web.vercel.app/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: CarouselSlider.builder(
        itemCount: bannerCards.length,
        itemBuilder: (context, index, realIndex) {
          return Container(
            height: 140,
            margin: const EdgeInsets.only(left: 0, right: 0, bottom: 20),
            padding: const EdgeInsets.only(left: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                stops: const [0.3, 0.7],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: bannerCards[index].cardBackground,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                if (index == 0) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: const Text('Telehealth Web View'),
                        ),
                        body: Stack(
                          children: [
                            WillPopScope(
                              onWillPop: () async {
                                String? url = await controller.currentUrl();
                                if (url == 'https://telehealth-app-web.vercel.app/') {
                                  return true;
                                } else {
                                  controller.goBack();
                                  return false;
                                }
                              },
                              child: WebViewWidget(controller: controller),
                            ),
                            isLoading ? const LoadingWidget() : Container(),
                          ],
                        ),
                      );
                    },
                  ));
                } else {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const AddMedicalRecord();
                    },
                  ));
                }
              },
              child: Stack(
                children: [
                  Image.asset(
                    bannerCards[index].image,
                    fit: BoxFit.fitHeight,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 7, right: 5),
                    alignment: Alignment.topRight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          bannerCards[index].text,
                          style: GoogleFonts.lato(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white54,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,
          scrollPhysics: const ClampingScrollPhysics(),
        ),
      ),
    );
  }
}
