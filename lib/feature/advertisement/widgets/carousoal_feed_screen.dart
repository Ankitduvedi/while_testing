import 'package:com.while.while_app/feature/advertisement/models/carousel_feed_scren_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});
  @override
  ImageCarouselState createState() => ImageCarouselState();
}

class ImageCarouselState extends State<ImageCarousel> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamgetImageUrls() {
    return firestore
        .collection('advertisement')
        .doc('carousel')
        .collection('a')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()['url'] as String).toList());
  }

  @override
  Widget build(BuildContext context) {
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
            aspectRatio: 2.0,
            enlargeCenterPage: true,
          ),
          items: data.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      child: CachedNetworkImage(
                        imageUrl: url.thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ));
              },
            );
          }).toList(),
        );
      },
    );
  }
}
