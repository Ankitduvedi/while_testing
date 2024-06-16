import 'dart:developer';

import 'package:com.while.while_app/feature/advertisement/models/carousel_feed_scren_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});
  @override
  ImageCarouselState createState() => ImageCarouselState();
}

class ImageCarouselState extends State<ImageCarousel> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Future<void> _launchUrl(String url) async {
      log('function clicked');
      if (!await launchUrl(Uri.parse(url))) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }

    return StreamBuilder(
      stream: firestore
          .collection('advertisement')
          .doc('carousel')
          .collection('a')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No images found'));
        }

        final data = snapshot.data!.docs
            .map((e) => AdCarousel.fromMap(e.data()))
            .toList();
        return CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 9 / 16,
            enlargeCenterPage: true,
          ),
          items: data.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => _launchUrl(url.website),
                  child: Card(
                    color: Colors.black,
                    elevation: 2.0,
                    child: Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                          child: CachedNetworkImage(
                            imageUrl: url.thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Ad. ${url.organisation}',
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 16.0,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
