import 'package:flutter_laundry_offline_app/data/models/expense_entry.dart';

class OcrService {
  static ExpenseEntry parseReceiptText(String rawText) {
    String item = extractItems(rawText);
    int nominal = extractTotalNominal(rawText);
    DateTime tanggal = extractDate(rawText);
    String supplier = extractSupplier(rawText);

    return ExpenseEntry(
      type: 'keluar', // Default assumption for receipts
      item: item,
      nominal: nominal,
      tanggal: tanggal,
      supplier: supplier,
      source: 'ocr',
      rawText: rawText,
      createdAt: DateTime.now(),
    );
  }

  static int extractTotalNominal(String text) {
    final lines = text.toLowerCase().split('\n');
    int maxNumber = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('total') || line.contains('jumlah')) {
        // try to find number in this line or next line
        final number = _extractLargestNumberFromLine(line);
        if (number > 0) return number;

        if (i + 1 < lines.length) {
          final nextNumber = _extractLargestNumberFromLine(lines[i + 1]);
          if (nextNumber > 0) return nextNumber;
        }
      } else {
        final number = _extractLargestNumberFromLine(line);
        if (number > maxNumber) {
          maxNumber = number;
        }
      }
    }
    return maxNumber > 0 ? maxNumber : 0;
  }

  static int _extractLargestNumberFromLine(String line) {
    // Remove non digit characters except comma and dot
    final RegExp regExp = RegExp(r'\d+[.,\d]*');
    final matches = regExp.allMatches(line);
    
    int maxNumber = 0;
    for (final match in matches) {
      String numStr = match.group(0) ?? '';
      // Clean up punctuation
      numStr = numStr.replaceAll(RegExp(r'[.,]'), '');
      if (numStr.isNotEmpty) {
        final number = int.tryParse(numStr) ?? 0;
        if (number > maxNumber) {
          maxNumber = number;
        }
      }
    }
    return maxNumber;
  }

  static DateTime extractDate(String text) {
    // Basic regex for DD/MM/YYYY or DD-MM-YYYY
    final RegExp dateRegExp = RegExp(r'\b(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})\b');
    final match = dateRegExp.firstMatch(text);
    if (match != null) {
      try {
        final day = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        int year = int.parse(match.group(3)!);
        if (year < 100) year += 2000;
        return DateTime(year, month, day);
      } catch (e) {
        // Fallback
      }
    }
    return DateTime.now(); // Fallback to current date
  }

  static String extractItems(String text) {
    final lines = text.split('\n');
    if (lines.length > 2) {
      // Return a chunk of lines that likely contains items (skipping header)
      return lines.skip(1).take(2).join(', ');
    }
    return 'Item dari Nota';
  }

  static String extractSupplier(String text) {
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      return lines.first.trim(); // First line is usually the store name
    }
    return 'Toko Tidak Diketahui';
  }
}
