import 'package:flutter_laundry_offline_app/data/models/expense_entry.dart';

class VoiceParseResult {
  final bool success;
  final ExpenseEntry? entry;
  final String rawText;
  final String confidence;
  final String? detectedCommand;
  final String? feedbackMessage;

  VoiceParseResult({
    required this.success,
    this.entry,
    required this.rawText,
    required this.confidence,
    this.detectedCommand,
    this.feedbackMessage,
  });
}

class VoiceTransactionParser {
  static const Map<String, List<String>> _voiceCommands = {
    'simpan': [
      'simpan',
      'save',
      'oke',
      'ok',
      'konfirmasi',
      'sudah benar',
      'catat',
      'ya',
      'benar',
    ],
    'batal': ['batal', 'cancel', 'hapus', 'jangan', 'batalin', 'tidak'],
    'ulangi': ['ulang', 'ulangi', 'rekam ulang', 'coba lagi', 'reset'],
    'kembali': ['kembali', 'back', 'tutup'],
    'lanjut': ['lanjut', 'next', 'selanjutnya', 'berikutnya'],
    'bantuan': ['bantuan', 'help', 'panduan', 'cara pakai'],
  };

  int extractNominal(String text) {
    if (text.trim().isEmpty) return 0;

    String cleanText = text.toLowerCase().trim();

    final Map<String, int> slang = {
      'cepek ceng': 100000,
      'setengah juta': 500000,
      'setengah ribu': 500,
      'seceng': 1000,
      'noceng': 2000,
      'goceng': 5000,
      'ceng': 1000,
      'ceban': 10000,
      'noban': 20000,
      'jigo': 25000,
      'goban': 50000,
      'gocap': 50000,
      'cepek': 100,
      'pego': 150,
      'nopek': 200,
      'gopek': 500,
    };

    for (final s in slang.entries) {
      if (cleanText.contains(s.key)) {
        return s.value;
      }
    }

    final kMatch = RegExp(r'(\d+)\s*k\b').firstMatch(cleanText);
    if (kMatch != null) {
      final val = int.tryParse(kMatch.group(1)!) ?? 0;
      if (val > 0) return val * 1000;
    }

    final directNumberMatch = RegExp(
      r'(?:rp\.?\s*)?(\d{1,3}(?:[.,]\d{3})+|\d+)',
    ).allMatches(cleanText);
    for (final match in directNumberMatch) {
      final matchedStr = match.group(1);
      if (matchedStr != null) {
        final cleanNum = matchedStr.replaceAll(RegExp(r'[.,]'), '');
        final parsed = int.tryParse(cleanNum);
        if (parsed != null && parsed >= 100) {
          final afterMatch = cleanText.substring(match.end).trim();
          if (afterMatch.startsWith('juta') || afterMatch.startsWith('jt')) {
            return parsed * 1000000;
          } else if (afterMatch.startsWith('ribu') ||
              afterMatch.startsWith('rb')) {
            return parsed * 1000;
          }
          return parsed;
        }
      }
    }

    final decimalMultiplierMatch = RegExp(
      r'(\d+[.,]\d+)\s*(juta|jt|ribu|rb)',
    ).firstMatch(cleanText);
    if (decimalMultiplierMatch != null) {
      final numPart =
          double.tryParse(
            decimalMultiplierMatch.group(1)!.replaceAll(',', '.'),
          ) ??
          0;
      final unitPart = decimalMultiplierMatch.group(2)!;
      if (unitPart.startsWith('j') || unitPart == 'jt') {
        return (numPart * 1000000).round();
      } else {
        return (numPart * 1000).round();
      }
    }

    return _parseIndonesianWordsToNumber(cleanText);
  }

  int _parseIndonesianWordsToNumber(String text) {
    String t = text
        .replaceAll('seribu', 'satu ribu')
        .replaceAll('sejuta', 'satu juta')
        .replaceAll('seratus', 'satu ratus')
        .replaceAll('sepuluh', 'satu puluh')
        .replaceAll('sebelas', '11')
        .replaceAll('duapuluh', 'dua puluh')
        .replaceAll('tigapuluh', 'tiga puluh')
        .replaceAll('empatpuluh', 'empat puluh')
        .replaceAll('limapuluh', 'lima puluh')
        .replaceAll('enampuluh', 'enam puluh')
        .replaceAll('tujuhpuluh', 'tujuh puluh')
        .replaceAll('delapanpuluh', 'delapan puluh')
        .replaceAll('sembilanpuluh', 'sembilan puluh')
        .replaceAll('duaratus', 'dua ratus')
        .replaceAll('tigaratus', 'tiga ratus')
        .replaceAll('empatratus', 'empat ratus')
        .replaceAll('limaratus', 'lima ratus')
        .replaceAll('duaribu', 'dua ribu')
        .replaceAll('tigaribu', 'tiga ribu')
        .replaceAll('limaribu', 'lima ribu')
        .replaceAll('sepuluhribu', 'sepuluh ribu');

    final tokens = t.split(RegExp(r'\s+'));
    int total = 0;
    int currentChunk = 0;
    int currentSub = 0;

    final Map<String, int> units = {
      'nol': 0,
      'satu': 1,
      'dua': 2,
      'tiga': 3,
      'empat': 4,
      'lima': 5,
      'enam': 6,
      'tujuh': 7,
      'delapan': 8,
      'sembilan': 9,
      'sepuluh': 10,
      'sebelas': 11,
      '11': 11,
    };

    for (int i = 0; i < tokens.length; i++) {
      final word = tokens[i];

      if (units.containsKey(word)) {
        currentSub += units[word]!;
      } else if (int.tryParse(word) != null) {
        currentSub += int.parse(word);
      } else if (word == 'belas') {
        if (currentSub > 0 && currentSub < 10) {
          currentSub += 10;
        } else {
          currentSub = 10;
        }
      } else if (word == 'puluh') {
        if (currentSub == 0) currentSub = 1;
        currentSub *= 10;
      } else if (word == 'ratus') {
        if (currentSub == 0) currentSub = 1;
        currentSub *= 100;
        currentChunk += currentSub;
        currentSub = 0;
      } else if (word == 'ribu' || word == 'rb') {
        if (currentSub == 0 && currentChunk == 0) currentSub = 1;
        currentChunk += currentSub;
        total += currentChunk * 1000;
        currentChunk = 0;
        currentSub = 0;
      } else if (word == 'juta' || word == 'jt') {
        if (currentSub == 0 && currentChunk == 0) currentSub = 1;
        currentChunk += currentSub;
        total += currentChunk * 1000000;
        currentChunk = 0;
        currentSub = 0;
      }
    }

    currentChunk += currentSub;
    total += currentChunk;

    return total;
  }

  String? detectCommand(String text) {
    final lower = text.toLowerCase().trim();
    for (final entry in _voiceCommands.entries) {
      for (final kw in entry.value) {
        if (lower == kw || lower.startsWith('$kw ') || lower.endsWith(' $kw')) {
          return entry.key;
        }
      }
    }
    return null;
  }

  VoiceParseResult parseTransaction(String text) {
    if (text.trim().isEmpty) {
      return VoiceParseResult(
        success: false,
        rawText: text,
        confidence: 'none',
        feedbackMessage: 'Suara tidak terdeteksi. Silakan coba lagi.',
      );
    }

    final command = detectCommand(text);

    String lowerText = text.toLowerCase().trim();
    String type = '';
    String item = text;

    final List<String> masukKeywords = [
      'terjual',
      'laku',
      'jual',
      'penjualan',
      'omset',
      'omzet',
      'masuk',
      'dapat',
      'pendapatan',
      'terima',
      'order',
    ];
    final List<String> keluarKeywords = [
      'beli',
      'bayar',
      'keluar',
      'belanja',
      'kulakan',
      'kulak',
      'pengeluaran',
      'ongkir',
      'gaji',
      'listrik',
      'sewa',
      'biaya',
    ];

    String? matchedKeyword;

    for (final kw in masukKeywords) {
      if (lowerText.contains(kw)) {
        type = 'masuk';
        matchedKeyword = kw;
        break;
      }
    }

    if (type.isEmpty) {
      for (final kw in keluarKeywords) {
        if (lowerText.contains(kw)) {
          type = 'keluar';
          matchedKeyword = kw;
          break;
        }
      }
    }

    if (type.isEmpty) {
      type = 'keluar';
    }

    final int nominal = extractNominal(text);

    if (matchedKeyword != null) {
      item = text
          .replaceAll(RegExp(matchedKeyword, caseSensitive: false), '')
          .trim();
    }

    final removeWords = [
      'rp',
      'rupiah',
      'sebesar',
      'seharga',
      'senilai',
      'ribu',
      'rb',
      'juta',
      'jt',
      'satu',
      'dua',
      'tiga',
      'empat',
      'lima',
      'enam',
      'tujuh',
      'delapan',
      'sembilan',
      'sepuluh',
      'sebelas',
      'belas',
      'puluh',
      'ratus',
      'seratus',
      'seribu',
      'sejuta',
      'sebanyak',
      'seharga',
      'total',
    ];

    final itemWords = item.split(RegExp(r'\s+')).where((w) {
      final cleanW = w.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (int.tryParse(cleanW) != null) return false;
      return !removeWords.contains(cleanW);
    }).toList();

    item = itemWords.join(' ').trim();

    if (item.isEmpty) {
      item = type == 'masuk' ? 'Penjualan' : 'Pengeluaran';
    } else {
      item = item[0].toUpperCase() + (item.length > 1 ? item.substring(1) : '');
    }

    String confidence = 'none';
    String feedback = '';

    if (nominal > 0 && item.isNotEmpty) {
      confidence = 'high';
      feedback =
          'Tercatat ${type == "masuk" ? "Pemasukan" : "Pengeluaran"}: $item senilai Rp $nominal';
    } else if (nominal > 0 || item.isNotEmpty) {
      confidence = 'low';
      feedback = 'Data transaksi belum lengkap. Mohon periksa kembali.';
    } else {
      confidence = 'none';
      feedback =
          'Tidak dapat mengenali detail transaksi. Silakan masukkan secara manual.';
    }

    ExpenseEntry? entry;
    if (confidence != 'none') {
      entry = ExpenseEntry(
        id: null,
        type: type,
        item: item,
        nominal: nominal,
        tanggal: DateTime.now(),
        supplier: '',
        source: 'voice',
        rawText: text,
        createdAt: DateTime.now(),
      );
    }

    return VoiceParseResult(
      success: confidence != 'none',
      entry: entry,
      rawText: text,
      confidence: confidence,
      detectedCommand: command,
      feedbackMessage: feedback,
    );
  }
}
