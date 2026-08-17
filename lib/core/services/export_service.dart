import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams, XFile;
import 'package:flutter_laundry_offline_app/data/models/order.dart';
import 'package:flutter_laundry_offline_app/data/models/expense_entry.dart';
import 'package:flutter_laundry_offline_app/core/utils/currency_formatter.dart';
import 'package:flutter_laundry_offline_app/core/utils/date_formatter.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/report/report_state.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<String> exportOrdersToExcel(
    List<Order> orders,
    ReportData reportData,
  ) async {
    final excel = Excel.createExcel();

    _createSummarySheet(excel, reportData);

    _createExpensesSheet(excel, reportData.expenses);

    _createOrdersSheet(excel, orders);

    _createServiceSummarySheet(excel, reportData);

    excel.delete('Sheet1');

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'Laporan_${DateFormatter.formatDateCompact(reportData.startDate)}_${DateFormatter.formatDateCompact(reportData.endDate)}.xlsx';
    final filePath = '${directory.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      return filePath;
    }

    throw Exception('Gagal membuat file Excel');
  }

  Future<String> exportReportToPdf(
    List<Order> orders,
    ReportData reportData,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'LAPORAN KEUANGAN — LegaliKas AI',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Periode: ${DateFormatter.formatDate(reportData.startDate)} - ${DateFormatter.formatDate(reportData.endDate)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 24),

            pw.Text(
              'Ringkasan Keuangan',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellPadding: const pw.EdgeInsets.all(6),
              data: [
                ['Metrik Keuangan', 'Nilai'],
                [
                  'Total Pemasukan',
                  CurrencyFormatter.format(reportData.totalIncome),
                ],
                [
                  'Total Pengeluaran',
                  CurrencyFormatter.format(reportData.totalExpense),
                ],
                [
                  'Laba / Saldo Bersih',
                  CurrencyFormatter.format(reportData.netProfit),
                ],
                ['Total Order', '${reportData.totalOrders}'],
                [
                  'Total Omzet POS',
                  CurrencyFormatter.format(reportData.totalRevenue),
                ],
              ],
            ),
            pw.SizedBox(height: 20),

            if (reportData.expenses.isNotEmpty) ...[
              pw.Text(
                'Buku Kas (Catatan Pemasukan & Pengeluaran)',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellPadding: const pw.EdgeInsets.all(3),
                cellStyle: const pw.TextStyle(fontSize: 9),
                data: [
                  ['Tanggal', 'Tipe', 'Item / Keterangan', 'Sumber', 'Nominal'],
                  ...reportData.expenses
                      .take(20)
                      .map(
                        (e) => [
                          DateFormatter.formatDateCompact(e.tanggal),
                          e.type == 'masuk' ? 'Pemasukan' : 'Pengeluaran',
                          e.item,
                          e.source.toUpperCase(),
                          CurrencyFormatter.format(e.nominal),
                        ],
                      ),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            if (reportData.dailyRevenue.isNotEmpty) ...[
              pw.Text(
                'Pendapatan Harian',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellPadding: const pw.EdgeInsets.all(4),
                data: [
                  ['Tanggal', 'Order', 'Omzet', 'Dibayar'],
                  ...reportData.dailyRevenue.map(
                    (d) => [
                      DateFormatter.formatDate(d.date),
                      '${d.orderCount}',
                      CurrencyFormatter.format(d.revenue),
                      CurrencyFormatter.format(d.paid),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            if (orders.isNotEmpty) ...[
              pw.Text(
                'Daftar Order',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellPadding: const pw.EdgeInsets.all(3),
                cellStyle: const pw.TextStyle(fontSize: 9),
                data: [
                  [
                    'Invoice',
                    'Tanggal',
                    'Pelanggan',
                    'Status',
                    'Total',
                    'Dibayar',
                  ],
                  ...orders.map(
                    (o) => [
                      o.invoiceNo,
                      DateFormatter.formatDateCompact(o.orderDate),
                      o.customerName,
                      o.status.displayName,
                      CurrencyFormatter.format(o.totalPrice),
                      CurrencyFormatter.format(o.paid),
                    ],
                  ),
                ],
              ),
            ],

            pw.SizedBox(height: 32),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text(
              'Dicetak oleh LegaliKas AI pada ${DateFormatter.formatDateTime(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'Laporan_${DateFormatter.formatDateCompact(reportData.startDate)}_${DateFormatter.formatDateCompact(reportData.endDate)}.pdf';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  void _createSummarySheet(Excel excel, ReportData reportData) {
    final sheet = excel['Ringkasan'];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      'LAPORAN TOKO',
    );
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
      'Periode: ${DateFormatter.formatDate(reportData.startDate)} - ${DateFormatter.formatDate(reportData.endDate)}',
    );

    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue(
      'Ringkasan',
    );

    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue(
      'Total Order',
    );
    sheet.cell(CellIndex.indexByString('B6')).value = IntCellValue(
      reportData.totalOrders,
    );

    sheet.cell(CellIndex.indexByString('A7')).value = TextCellValue(
      'Order Selesai',
    );
    sheet.cell(CellIndex.indexByString('B7')).value = IntCellValue(
      reportData.completedOrders,
    );

    sheet.cell(CellIndex.indexByString('A8')).value = TextCellValue(
      'Order Pending',
    );
    sheet.cell(CellIndex.indexByString('B8')).value = IntCellValue(
      reportData.pendingOrders,
    );

    sheet.cell(CellIndex.indexByString('A10')).value = TextCellValue(
      'Total Omzet',
    );
    sheet.cell(CellIndex.indexByString('B10')).value = TextCellValue(
      CurrencyFormatter.format(reportData.totalRevenue),
    );

    sheet.cell(CellIndex.indexByString('A11')).value = TextCellValue(
      'Total Dibayar',
    );
    sheet.cell(CellIndex.indexByString('B11')).value = TextCellValue(
      CurrencyFormatter.format(reportData.totalPaid),
    );

    sheet.cell(CellIndex.indexByString('A12')).value = TextCellValue(
      'Total Belum Dibayar',
    );
    sheet.cell(CellIndex.indexByString('B12')).value = TextCellValue(
      CurrencyFormatter.format(reportData.totalUnpaid),
    );

    sheet.cell(CellIndex.indexByString('A14')).value = TextCellValue(
      'Pendapatan Harian',
    );

    sheet.cell(CellIndex.indexByString('A15')).value = TextCellValue('Tanggal');
    sheet.cell(CellIndex.indexByString('B15')).value = TextCellValue(
      'Jumlah Order',
    );
    sheet.cell(CellIndex.indexByString('C15')).value = TextCellValue('Omzet');
    sheet.cell(CellIndex.indexByString('D15')).value = TextCellValue('Dibayar');

    int row = 16;
    for (final daily in reportData.dailyRevenue) {
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
        DateFormatter.formatDate(daily.date),
      );
      sheet.cell(CellIndex.indexByString('B$row')).value = IntCellValue(
        daily.orderCount,
      );
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(
        CurrencyFormatter.format(daily.revenue),
      );
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(
        CurrencyFormatter.format(daily.paid),
      );
      row++;
    }
  }

  void _createOrdersSheet(Excel excel, List<Order> orders) {
    final sheet = excel['Daftar Order'];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      'No Invoice',
    );
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Tanggal');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue(
      'Pelanggan',
    );
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('No HP');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Status');
    sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Total');
    sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Dibayar');
    sheet.cell(CellIndex.indexByString('H1')).value = TextCellValue('Kurang');

    int row = 2;
    for (final order in orders) {
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
        order.invoiceNo,
      );
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(
        DateFormatter.formatDateTime(order.orderDate),
      );
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(
        order.customerName,
      );
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(
        order.customerPhone ?? '-',
      );
      sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(
        order.status.displayName,
      );
      sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(
        CurrencyFormatter.format(order.totalPrice),
      );
      sheet.cell(CellIndex.indexByString('G$row')).value = TextCellValue(
        CurrencyFormatter.format(order.paid),
      );
      sheet.cell(CellIndex.indexByString('H$row')).value = TextCellValue(
        CurrencyFormatter.format(order.remainingPayment),
      );
      row++;
    }
  }

  void _createExpensesSheet(Excel excel, List<ExpenseEntry> expenses) {
    final sheet = excel['Buku Kas'];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Tanggal');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Tipe');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue(
      'Keterangan / Item',
    );
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Nominal');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue(
      'Sumber Input',
    );
    sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue(
      'Supplier / Toko',
    );

    int row = 2;
    for (final exp in expenses) {
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
        DateFormatter.formatDateTime(exp.tanggal),
      );
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(
        exp.type == 'masuk' ? 'Pemasukan' : 'Pengeluaran',
      );
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(
        exp.item,
      );
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(
        CurrencyFormatter.format(exp.nominal),
      );
      sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(
        exp.source.toUpperCase(),
      );
      sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(
        exp.supplier ?? '-',
      );
      row++;
    }
  }

  void _createServiceSummarySheet(Excel excel, ReportData reportData) {
    final sheet = excel['Produk Populer'];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      'Nama Produk',
    );
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
      'Jumlah Order',
    );
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue(
      'Total Qty',
    );
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue(
      'Total Pendapatan',
    );

    int row = 2;
    for (final service in reportData.topServices) {
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
        service.serviceName,
      );
      sheet.cell(CellIndex.indexByString('B$row')).value = IntCellValue(
        service.orderCount,
      );
      sheet.cell(CellIndex.indexByString('C$row')).value = IntCellValue(
        service.totalQuantity,
      );
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(
        CurrencyFormatter.format(service.totalRevenue),
      );
      row++;
    }
  }

  Future<void> shareFile(String filePath) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: 'Laporan Toko'),
    );
  }
}
