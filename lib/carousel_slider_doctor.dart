import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telehealth_app/globals.dart';
import 'package:telehealth_app/model/banner_model.dart';
import 'package:telehealth_app/screens/doctor/add_medical_record.dart';
import 'package:telehealth_app/screens/view_medical_record.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'loading_widget.dart';

class CarouselsliderDoctor extends StatefulWidget {
  const CarouselsliderDoctor({super.key});

  @override
  State<CarouselsliderDoctor> createState() => _CarouselsliderDoctorState();
}

class _CarouselsliderDoctorState extends State<CarouselsliderDoctor> {
  bool isLoading = true;
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    // if (Platform.isAndroid) {
    //   WebView.platform = SurfaceAndroidWebView(); // Ensure WebView is set for Android
    // }

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://telehealth-training-web-app.netlify.app'));
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
                print('isDoctor: $isDoctor');
                if (index == 0) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: const Text('Telehealth Web View'),
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () async {
                              // Check if WebView can go back
                              if (await controller.canGoBack()) {
                                controller.goBack();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                        body: Stack(
                          children: [
                            WillPopScope(
                              onWillPop: () async {
                                if (await controller.canGoBack()) {
                                  controller.goBack();
                                  return false; // Prevent app from closing
                                } else {
                                  return true; // Exit the WebView
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
                      return isDoctor ? const AddMedicalRecord() : const ViewMedicalRecords();
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
