 import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends StatefulWidget {
  final String url;

  const PdfView({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  @override
  Widget build(BuildContext context) {
    // Directly access `url` from the widget property.
    return SfPdfViewer.network(widget.url);
  }
}
