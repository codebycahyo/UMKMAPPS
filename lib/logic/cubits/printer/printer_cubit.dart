import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laundry_offline_app/core/services/printer_service.dart';
import 'package:flutter_laundry_offline_app/data/models/order.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/printer/printer_state.dart';

class PrinterCubit extends Cubit<PrinterState> {
  final PrinterService _printerService;

  PrinterCubit({PrinterService? printerService})
    : _printerService = printerService ?? PrinterService(),
      super(const PrinterInitial());

  String get currentPaperSize => _printerService.paperSize;

  Future<void> initialize() async {
    await _printerService.initialize();
    await loadDevices();
  }

  Future<void> loadDevices() async {
    emit(const PrinterLoading());

    try {
      bool isAvailable = false;
      try {
        isAvailable = await _printerService.isBluetoothAvailable().timeout(
          const Duration(seconds: 5),
          onTimeout: () => false,
        );
      } catch (_) {
        isAvailable = false;
      }

      final paperSize = await _printerService.getSavedPaperSize();

      if (!isAvailable) {
        emit(
          PrinterDevicesLoaded(
            devices: const [],
            paperSize: paperSize,
            bluetoothEnabled: false,
          ),
        );
        return;
      }

      List<BluetoothDevice> devices = [];
      try {
        devices = await _printerService.getPairedDevices().timeout(
          const Duration(seconds: 5),
          onTimeout: () => [],
        );
      } catch (_) {
        devices = [];
      }

      final savedPrinter = await _printerService.getSavedPrinter();
      final savedMac = savedPrinter['mac'];

      BluetoothDevice? connectedDevice;
      try {
        final isConnected = await _printerService.checkConnection().timeout(
          const Duration(seconds: 3),
          onTimeout: () => false,
        );

        if (isConnected && _printerService.connectedDeviceAddress != null) {
          connectedDevice = devices.firstWhere(
            (d) => d.address == _printerService.connectedDeviceAddress,
            orElse: () => BluetoothDevice(
              name: _printerService.connectedDeviceName ?? 'Unknown',
              address: _printerService.connectedDeviceAddress!,
            ),
          );
        } else if (savedMac != null && savedMac.isNotEmpty) {
          final savedDevice = devices
              .where((d) => d.address == savedMac)
              .firstOrNull;
          if (savedDevice != null) {
            connectedDevice = null;
          }
        }
      } catch (_) {}

      emit(
        PrinterDevicesLoaded(
          devices: devices,
          connectedDevice: connectedDevice,
          paperSize: paperSize,
          bluetoothEnabled: true,
          savedPrinterMac: savedMac,
        ),
      );
    } catch (e) {
      emit(const PrinterDevicesLoaded(devices: []));
    }
  }

  Future<void> connectDevice(BluetoothDevice device) async {
    emit(PrinterConnecting(device.name));

    try {
      final success = await _printerService.connect(device);
      if (success) {
        emit(PrinterConnected(device.name));

        await loadDevices();
      } else {
        emit(const PrinterError('Gagal terhubung ke printer'));
        await loadDevices();
      }
    } catch (e) {
      emit(PrinterError(e.toString().replaceAll('Exception: ', '')));
      await loadDevices();
    }
  }

  Future<void> disconnectDevice() async {
    emit(const PrinterLoading());

    try {
      await _printerService.disconnect();
      emit(const PrinterDisconnected());
      await loadDevices();
    } catch (e) {
      emit(PrinterError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> printReceipt(Order order) async {
    emit(const PrinterPrinting());

    try {
      final success = await _printerService.printReceipt(order);
      if (success) {
        emit(const PrinterPrintSuccess('Struk berhasil dicetak'));
      } else {
        emit(const PrinterError('Gagal mencetak struk'));
      }
    } catch (e) {
      emit(PrinterError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<bool> checkConnection() async {
    return await _printerService.checkConnection();
  }

  Future<void> setPaperSize(String size) async {
    await _printerService.setPaperSize(size);
    await loadDevices();
  }

  Future<void> printTest() async {
    emit(const PrinterPrinting());

    try {
      final success = await _printerService.printTest();
      if (success) {
        emit(const PrinterPrintSuccess('Test print berhasil'));
      } else {
        emit(const PrinterError('Gagal mencetak test'));
      }
      await loadDevices();
    } catch (e) {
      emit(PrinterError(e.toString().replaceAll('Exception: ', '')));
      await loadDevices();
    }
  }
}
