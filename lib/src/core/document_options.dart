import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

/// These are the general configuration for
/// the pdf document and general view mode and orientation
class DocumentOptions {
  final String? title;
  final String? author;
  final String? creator;
  final String? subject;
  final String? keywords;
  final String? producer;

  /// Display hint for the PDF viewer
  final PdfPageMode mode;

  /// The orientation of the page
  final PageOrientation orientation;
  final PdfVersion version;
  final int? maxPages;

  const DocumentOptions({
    this.title,
    this.author,
    this.creator,
    this.subject,
    this.keywords,
    this.producer,
    this.version = PdfVersion.pdf_1_5,
    this.orientation = PageOrientation.portrait,
    this.mode = PdfPageMode.outlines,
    this.maxPages,
  }) : assert(maxPages == null || maxPages > 0,
            'maxPages cannot be less than zero');
}
