import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_laundry_offline_app/data/models/order.dart';
import 'package:flutter_laundry_offline_app/core/services/laundry_print.dart';

class BluetoothDevice {
  final String name;
  final String address;

  BluetoothDevice({required this.name, required this.address});
}

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  static const String _keyPrinterMac = 'printer_mac';
  static const String _keyPrinterName = 'printer_name';
  static const String _keyPaperSize = 'paper_size';

  String? _connectedAddress;
  String? _connectedName;
  String _paperSize = '58';

  bool get isConnected => _connectedAddress != null;
  String? get connectedDeviceName => _connectedName;
  String? get connectedDeviceAddress => _connectedAddress;
  String get paperSize => _paperSize;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _connectedAddress = prefs.getString(_keyPrinterMac);
    _connectedName = prefs.getString(_keyPrinterName);
    _paperSize = prefs.getString(_keyPaperSize) ?? '58';

    if (_connectedAddress != null && _connectedAddress!.isNotEmpty) {
      await connect(
        BluetoothDevice(
          name: _connectedName ?? 'Unknown',
          address: _connectedAddress!,
        ),
      );
    }
  }

  Future<bool> isBluetoothAvailable() async {
    final isAvailable = await PrintBluetoothThermal.bluetoothEnabled;
    return isAvailable;
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    final List<BluetoothInfo> devices =
        await PrintBluetoothThermal.pairedBluetooths;
    return devices
        .map((d) => BluetoothDevice(name: d.name, address: d.macAdress))
        .toList();
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.address,
      );
      if (result) {
        _connectedAddress = device.address;
        _connectedName = device.name;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyPrinterMac, device.address);
        await prefs.setString(_keyPrinterName, device.name);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    _connectedAddress = null;
    _connectedName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrinterMac);
    await prefs.remove(_keyPrinterName);
  }

  Future<bool> checkConnection() async {
    if (_connectedAddress == null) {
      final prefs = await SharedPreferences.getInstance();
      _connectedAddress = prefs.getString(_keyPrinterMac);
      _connectedName = prefs.getString(_keyPrinterName);
      if (_connectedAddress == null) return false;
    }

    final status = await PrintBluetoothThermal.connectionStatus;
    return status;
  }

  Future<Map<String, String?>> getSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'mac': prefs.getString(_keyPrinterMac),
      'name': prefs.getString(_keyPrinterName),
    };
  }

  Future<bool> reconnectSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMac = prefs.getString(_keyPrinterMac);
    final savedName = prefs.getString(_keyPrinterName);

    if (savedMac == null || savedMac.isEmpty) return false;

    final currentStatus = await PrintBluetoothThermal.connectionStatus;
    if (currentStatus) {
      _connectedAddress = savedMac;
      _connectedName = savedName;
      return true;
    }

    return await connect(
      BluetoothDevice(name: savedName ?? 'Printer', address: savedMac),
    );
  }

  Future<void> setPaperSize(String size) async {
    _paperSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPaperSize, size);
  }

  Future<String> getSavedPaperSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPaperSize) ?? '58';
  }

  PaperSize getPaperSizeEnum() {
    return _paperSize == '80' ? PaperSize.mm80 : PaperSize.mm58;
  }

  Future<bool> ensureConnected() async {
    final prefs = await SharedPreferences.getInstance();
    _paperSize = prefs.getString(_keyPaperSize) ?? '58';

    if (await checkConnection()) {
      return true;
    }

    return await reconnectSavedPrinter();
  }

  Future<bool> printReceipt(Order order) async {
    if (!await ensureConnected()) {
      throw Exception(
        'Printer tidak terhubung. Silakan hubungkan printer di Settings.',
      );
    }

    try {
      final bytes = await ReceiptPrint.instance.printOrderReceipt(
        order,
        paperSize: getPaperSizeEnum(),
        paperSizeMm: _paperSize,
      );
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      throw Exception('Gagal mencetak: ${e.toString()}');
    }
  }

  Future<bool> printTest() async {
    if (!await ensureConnected()) {
      throw Exception(
        'Printer tidak terhubung. Silakan hubungkan printer di Settings.',
      );
    }

    try {
      final bytes = await ReceiptPrint.instance.printTest(
        paperSize: getPaperSizeEnum(),
        paperSizeMm: _paperSize,
      );
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      throw Exception('Gagal mencetak: ${e.toString()}');
    }
  }
}
