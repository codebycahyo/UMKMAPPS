class AppConstants {
  AppConstants._();

  static const String appName = 'LegaliKas AI';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Aplikasi Pembukuan & Legalitas UMKM Indonesia - AI On-Device, Full Offline!';

  static const String databaseName = 'legalikas_pos.db';
  static const int databaseVersion = 4;

  static const String defaultInvoicePrefix = 'LKS';
  static const int invoiceNumberLength = 4;

  static const int defaultServiceDuration = 3;
  static const String defaultPaymentMethod = 'cash';

  static const int defaultPageSize = 20;
  static const int recentOrdersLimit = 5;

  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String dateFormatShort = 'dd/MM/yy';
  static const String timeFormat = 'HH:mm';
  static const String invoiceDateFormat = 'yyMMdd';

  static const int printerPaperWidth = 58;
  static const int printerCharPerLine = 32;

  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  static const String defaultOwnerUsername = 'owner';
  static const String defaultOwnerPassword = 'admin123';
  static const String defaultOwnerName = 'Pemilik UMKM';

  static const String keyStoreName = 'laundry_name';
  static const String keyStoreAddress = 'laundry_address';
  static const String keyStorePhone = 'laundry_phone';
  static const String keyLaundryName = keyStoreName;
  static const String keyLaundryAddress = keyStoreAddress;
  static const String keyLaundryPhone = keyStorePhone;
  static const String keyInvoicePrefix = 'invoice_prefix';
  static const String keyPrinterAddress = 'printer_address';
  static const String keyLastInvoiceDate = 'last_invoice_date';
  static const String keyLastInvoiceNumber = 'last_invoice_number';

  static const String defaultStoreName = 'LegaliKas AI';
  static const String defaultStoreAddress = 'Jl. UMKM Berdaya No. 1';
  static const String defaultStorePhone = '6281234567890';
  static const String defaultLaundryName = defaultStoreName;
  static const String defaultLaundryAddress = defaultStoreAddress;
  static const String defaultLaundryPhone = defaultStorePhone;
}
