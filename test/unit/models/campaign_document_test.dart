import 'package:flutter_test/flutter_test.dart';
import 'package:divine_foundation/Screens/dashboard/campaign_details_screen.dart';
import 'package:divine_foundation/Model/campaign_details_model.dart';

void main() {
  group('CampaignDocument Parsing Tests', () {
    test('Correctly extracts metadata and clean fileUrl from sample identity document', () {
      const sampleUrl = 'https://i.ibb.co/1JJSgNdm/54f392b06e27.jpg#type=identity&name=1000189728.jpg';
      final doc = CampaignDocument.fromUrl(sampleUrl);

      expect(doc.fileUrl, equals('https://i.ibb.co/1JJSgNdm/54f392b06e27.jpg'));
      expect(doc.type, equals('identity'));
      expect(doc.formattedType, equals('Identity'));
      expect(doc.name, equals('1000189728.jpg'));
      expect(doc.fileName, equals('1000189728.jpg'));
      expect(doc.label, equals('Identity (1000189728.jpg)'));
      expect(doc.isImage, isTrue);
    });

    test('Correctly extracts metadata and clean fileUrl from sample medical document', () {
      const sampleUrl = 'https://files.catbox.moe/o6115c.jpg#type=medical&name=1000189728.jpg';
      final doc = CampaignDocument.fromUrl(sampleUrl);

      expect(doc.fileUrl, equals('https://files.catbox.moe/o6115c.jpg'));
      expect(doc.type, equals('medical'));
      expect(doc.formattedType, equals('Medical'));
      expect(doc.name, equals('1000189728.jpg'));
      expect(doc.fileName, equals('1000189728.jpg'));
      expect(doc.label, equals('Medical (1000189728.jpg)'));
      expect(doc.isImage, isTrue);
    });

    test('Handles document without metadata fragment safely', () {
      const sampleUrl = 'https://example.com/files/report.pdf';
      final doc = CampaignDocument.fromUrl(sampleUrl);

      expect(doc.fileUrl, equals('https://example.com/files/report.pdf'));
      expect(doc.type, isNull);
      expect(doc.name, equals('report.pdf'));
      expect(doc.fileName, equals('report.pdf'));
      expect(doc.label, equals('report.pdf'));
      expect(doc.isImage, isFalse);
    });

    test('Handles query parameter metadata (?type=medical&name=doc.jpg)', () {
      const sampleUrl = 'https://example.com/download.jpg?type=medical&name=medical_cert.jpg';
      final doc = CampaignDocument.fromUrl(sampleUrl);

      expect(doc.type, equals('medical'));
      expect(doc.name, equals('medical_cert.jpg'));
      expect(doc.label, equals('Medical (medical_cert.jpg)'));
    });
  });

  group('CampaignDetailsData Document Handling Tests', () {
    test('Parses documents list from json safely', () {
      final json = {
        'title': 'Save Wildlife',
        'documents': [
          'https://i.ibb.co/1JJSgNdm/54f392b06e27.jpg#type=identity&name=1000189728.jpg',
          'https://files.catbox.moe/o6115c.jpg#type=medical&name=1000189728.jpg',
        ],
      };

      final data = CampaignDetailsData.fromJson(json);
      expect(data.documents, isNotNull);
      expect(data.documents!.length, equals(2));
      expect(data.allDocuments.length, equals(2));
    });

    test('Handles null and empty documents safely', () {
      final json = {
        'title': 'No Documents Campaign',
        'documents': null,
      };

      final data = CampaignDetailsData.fromJson(json);
      expect(data.documents, isEmpty);
      expect(data.allDocuments, isEmpty);
    });
  });
}
