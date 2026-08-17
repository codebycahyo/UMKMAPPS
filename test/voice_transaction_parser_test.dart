import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_laundry_offline_app/core/utils/voice_transaction_parser.dart';

void main() {
  group('VoiceTransactionParser Tests', () {
    final parser = VoiceTransactionParser();

    test('Parses digits with ribu/juta', () {
      expect(parser.extractNominal('terjual 20 ribu'), 20000);
      expect(parser.extractNominal('beli bahan 150 rb'), 150000);
      expect(parser.extractNominal('omzet 1.5 juta'), 1500000);
      expect(parser.extractNominal('terjual Rp 25.000'), 25000);
      expect(parser.extractNominal('setengah juta'), 500000);
    });

    test('Parses Indonesian number words', () {
      expect(parser.extractNominal('dua puluh lima ribu'), 25000);
      expect(parser.extractNominal('seratus lima puluh ribu'), 150000);
      expect(parser.extractNominal('tiga ratus lima puluh ribu'), 350000);
      expect(parser.extractNominal('satu juta dua ratus ribu'), 1200000);
      expect(parser.extractNominal('sepuluh ribu'), 10000);
      expect(parser.extractNominal('lima belas ribu'), 15000);
    });

    test('Parses colloquial numbers and k-notation', () {
      expect(parser.extractNominal('gocap'), 50000);
      expect(parser.extractNominal('ceban'), 10000);
      expect(parser.extractNominal('noban'), 20000);
      expect(parser.extractNominal('jigo'), 25000);
      expect(parser.extractNominal('seceng'), 1000);
      expect(parser.extractNominal('50k'), 50000);
      expect(parser.extractNominal('100k'), 100000);
      expect(parser.extractNominal('limapuluh ribu'), 50000);
      expect(parser.extractNominal('duapuluh lima ribu'), 25000);
    });

    test('Detects voice commands accurately', () {
      expect(parser.detectCommand('simpan'), 'simpan');
      expect(parser.detectCommand('batal'), 'batal');
      expect(parser.detectCommand('ulangi'), 'ulangi');
      expect(parser.detectCommand('kembali'), 'kembali');
      expect(parser.detectCommand('lanjut'), 'lanjut');
      expect(parser.detectCommand('bantuan'), 'bantuan');
      expect(parser.detectCommand('sudah benar simpan'), 'simpan');
    });

    test('Parses full sentence into transaction entry', () {
      final res1 = parser.parseTransaction(
        'terjual nasi goreng dua puluh ribu',
      );
      expect(res1.success, true);
      expect(res1.confidence, 'high');
      expect(res1.entry?.type, 'masuk');
      expect(res1.entry?.nominal, 20000);
      expect(res1.entry?.item.toLowerCase().contains('nasi goreng'), true);

      final res2 = parser.parseTransaction(
        'beli minyak goreng seratus lima puluh ribu',
      );
      expect(res2.success, true);
      expect(res2.confidence, 'high');
      expect(res2.entry?.type, 'keluar');
      expect(res2.entry?.nominal, 150000);

      final res3 = parser.parseTransaction('simpan');
      expect(res3.detectedCommand, 'simpan');
    });
  });
}
