import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalalWizardState extends Equatable {
  final int currentStep;
  final bool isCompleted;

  // New fields
  final Map<int, List<bool>> documentChecklist;
  final DateTime? sehatiDeadline;

  static const Map<int, List<String>> defaultChecklistLabels = {
    0: ['KTP Pemilik', 'NIB / Izin Usaha', 'Foto Lokasi Usaha'],
    1: ['Daftar Bahan Baku Lengkap', 'Sertifikat Halal Supplier (jika ada)'],
    2: ['Foto Area Produksi', 'SOP Proses Produksi'],
    3: ['Bukti Kepemilikan/Sewa Lokasi', 'Foto Lokasi Produksi'],
    4: ['Tanda Tangan Pernyataan']
  };

  // Step 1
  final String namaUsaha;
  final String nib;
  final String alamatUsaha;
  final String teleponUsaha;

  // Step 2
  final List<String> bahanBaku;
  final List<String> bahanWaspada;

  // Step 3
  final String deskripsiProses;
  final String tempatProses;
  final bool prosesTerpisah;
  final bool alatTidakBersama;

  // Step 4
  final String alamatProduksi;
  final String statusTempat;
  final String luasArea;
  final bool lokasiBersih;
  final bool lokasiTerpisahHaram;

  // Step 5
  final bool setujuPernyataan;

  const HalalWizardState({
    this.currentStep = 0,
    this.isCompleted = false,
    this.namaUsaha = '',
    this.nib = '',
    this.alamatUsaha = '',
    this.teleponUsaha = '',
    this.bahanBaku = const [],
    this.bahanWaspada = const [],
    this.deskripsiProses = '',
    this.tempatProses = '',
    this.prosesTerpisah = false,
    this.alatTidakBersama = false,
    this.alamatProduksi = '',
    this.statusTempat = 'Milik Sendiri',
    this.luasArea = '',
    this.lokasiBersih = false,
    this.lokasiTerpisahHaram = false,
    this.setujuPernyataan = false,
    this.documentChecklist = const {
      0: [false, false, false],
      1: [false, false],
      2: [false, false],
      3: [false, false],
      4: [false],
    },
    this.sehatiDeadline,
  });

  HalalWizardState copyWith({
    int? currentStep,
    bool? isCompleted,
    String? namaUsaha,
    String? nib,
    String? alamatUsaha,
    String? teleponUsaha,
    List<String>? bahanBaku,
    List<String>? bahanWaspada,
    String? deskripsiProses,
    String? tempatProses,
    bool? prosesTerpisah,
    bool? alatTidakBersama,
    String? alamatProduksi,
    String? statusTempat,
    String? luasArea,
    bool? lokasiBersih,
    bool? lokasiTerpisahHaram,
    bool? setujuPernyataan,
    Map<int, List<bool>>? documentChecklist,
    DateTime? sehatiDeadline,
  }) {
    return HalalWizardState(
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
      namaUsaha: namaUsaha ?? this.namaUsaha,
      nib: nib ?? this.nib,
      alamatUsaha: alamatUsaha ?? this.alamatUsaha,
      teleponUsaha: teleponUsaha ?? this.teleponUsaha,
      bahanBaku: bahanBaku ?? this.bahanBaku,
      bahanWaspada: bahanWaspada ?? this.bahanWaspada,
      deskripsiProses: deskripsiProses ?? this.deskripsiProses,
      tempatProses: tempatProses ?? this.tempatProses,
      prosesTerpisah: prosesTerpisah ?? this.prosesTerpisah,
      alatTidakBersama: alatTidakBersama ?? this.alatTidakBersama,
      alamatProduksi: alamatProduksi ?? this.alamatProduksi,
      statusTempat: statusTempat ?? this.statusTempat,
      luasArea: luasArea ?? this.luasArea,
      lokasiBersih: lokasiBersih ?? this.lokasiBersih,
      lokasiTerpisahHaram: lokasiTerpisahHaram ?? this.lokasiTerpisahHaram,
      setujuPernyataan: setujuPernyataan ?? this.setujuPernyataan,
      documentChecklist: documentChecklist ?? this.documentChecklist,
      sehatiDeadline: sehatiDeadline ?? this.sehatiDeadline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'isCompleted': isCompleted,
      'namaUsaha': namaUsaha,
      'nib': nib,
      'alamatUsaha': alamatUsaha,
      'teleponUsaha': teleponUsaha,
      'bahanBaku': bahanBaku,
      'bahanWaspada': bahanWaspada,
      'deskripsiProses': deskripsiProses,
      'tempatProses': tempatProses,
      'prosesTerpisah': prosesTerpisah,
      'alatTidakBersama': alatTidakBersama,
      'alamatProduksi': alamatProduksi,
      'statusTempat': statusTempat,
      'luasArea': luasArea,
      'lokasiBersih': lokasiBersih,
      'lokasiTerpisahHaram': lokasiTerpisahHaram,
      'setujuPernyataan': setujuPernyataan,
      'documentChecklist': documentChecklist.map((key, value) => MapEntry(key.toString(), value)),
      'sehatiDeadline': sehatiDeadline?.toIso8601String(),
    };
  }

  factory HalalWizardState.fromJson(Map<String, dynamic> json) {
    return HalalWizardState(
      currentStep: json['currentStep'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      namaUsaha: json['namaUsaha'] ?? '',
      nib: json['nib'] ?? '',
      alamatUsaha: json['alamatUsaha'] ?? '',
      teleponUsaha: json['teleponUsaha'] ?? '',
      bahanBaku: List<String>.from(json['bahanBaku'] ?? []),
      bahanWaspada: List<String>.from(json['bahanWaspada'] ?? []),
      deskripsiProses: json['deskripsiProses'] ?? '',
      tempatProses: json['tempatProses'] ?? '',
      prosesTerpisah: json['prosesTerpisah'] ?? false,
      alatTidakBersama: json['alatTidakBersama'] ?? false,
      alamatProduksi: json['alamatProduksi'] ?? '',
      statusTempat: json['statusTempat'] ?? 'Milik Sendiri',
      luasArea: json['luasArea'] ?? '',
      lokasiBersih: json['lokasiBersih'] ?? false,
      lokasiTerpisahHaram: json['lokasiTerpisahHaram'] ?? false,
      setujuPernyataan: json['setujuPernyataan'] ?? false,
      documentChecklist: json['documentChecklist'] != null
          ? (json['documentChecklist'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(int.parse(key), List<bool>.from(value)))
          : const {
              0: [false, false, false],
              1: [false, false],
              2: [false, false],
              3: [false, false],
              4: [false],
            },
      sehatiDeadline: json['sehatiDeadline'] != null
          ? DateTime.tryParse(json['sehatiDeadline'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        isCompleted,
        namaUsaha,
        nib,
        alamatUsaha,
        teleponUsaha,
        bahanBaku,
        bahanWaspada,
        deskripsiProses,
        tempatProses,
        prosesTerpisah,
        alatTidakBersama,
        alamatProduksi,
        statusTempat,
        luasArea,
        lokasiBersih,
        lokasiTerpisahHaram,
        setujuPernyataan,
        documentChecklist,
        sehatiDeadline,
      ];
}

class HalalWizardCubit extends Cubit<HalalWizardState> {
  static const String _prefKey = 'halal_wizard_state';

  HalalWizardCubit() : super(const HalalWizardState()) {
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        emit(HalalWizardState.fromJson(json));
      } catch (e) {
        // Fallback to initial state
      }
    }
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(state.toJson()));
  }

  void updateStep1Data({
    required String namaUsaha,
    required String nib,
    required String alamatUsaha,
    required String teleponUsaha,
  }) {
    emit(state.copyWith(
      namaUsaha: namaUsaha,
      nib: nib,
      alamatUsaha: alamatUsaha,
      teleponUsaha: teleponUsaha,
    ));
    saveProgress();
  }

  void updateStep2Data({
    required List<String> bahanBaku,
    required List<String> bahanWaspada,
  }) {
    emit(state.copyWith(
      bahanBaku: bahanBaku,
      bahanWaspada: bahanWaspada,
    ));
    saveProgress();
  }

  void updateStep3Data({
    required String deskripsiProses,
    required String tempatProses,
    required bool prosesTerpisah,
    required bool alatTidakBersama,
  }) {
    emit(state.copyWith(
      deskripsiProses: deskripsiProses,
      tempatProses: tempatProses,
      prosesTerpisah: prosesTerpisah,
      alatTidakBersama: alatTidakBersama,
    ));
    saveProgress();
  }

  void updateStep4Data({
    required String alamatProduksi,
    required String statusTempat,
    required String luasArea,
    required bool lokasiBersih,
    required bool lokasiTerpisahHaram,
  }) {
    emit(state.copyWith(
      alamatProduksi: alamatProduksi,
      statusTempat: statusTempat,
      luasArea: luasArea,
      lokasiBersih: lokasiBersih,
      lokasiTerpisahHaram: lokasiTerpisahHaram,
    ));
    saveProgress();
  }

  void updateStep5Data({required bool setujuPernyataan}) {
    emit(state.copyWith(setujuPernyataan: setujuPernyataan));
    saveProgress();
  }

  void toggleDocumentCheck(int step, int index) {
    final currentList = List<bool>.from(state.documentChecklist[step] ?? []);
    if (index >= 0 && index < currentList.length) {
      currentList[index] = !currentList[index];
      final newChecklist = Map<int, List<bool>>.from(state.documentChecklist);
      newChecklist[step] = currentList;
      emit(state.copyWith(documentChecklist: newChecklist));
      saveProgress();
    }
  }

  void setSehatiDeadline(DateTime deadline) {
    emit(state.copyWith(sehatiDeadline: deadline));
    saveProgress();
  }

  void clearSehatiDeadline() {
    // using copyWith with a workaround or explicitly creating a new state without deadline
    emit(state.copyWith(sehatiDeadline: null));
    saveProgress();
  }

  int getDocumentCompletionPercent() {
    int total = 0;
    int checked = 0;
    for (final list in state.documentChecklist.values) {
      total += list.length;
      checked += list.where((element) => element).length;
    }
    if (total == 0) return 0;
    return ((checked / total) * 100).round();
  }

  bool validateCurrentStep() {
    switch (state.currentStep) {
      case 0:
        return state.namaUsaha.trim().isNotEmpty &&
            state.nib.trim().isNotEmpty &&
            state.alamatUsaha.trim().isNotEmpty;
      case 1:
        return state.bahanBaku.isNotEmpty;
      case 2:
        return state.deskripsiProses.trim().isNotEmpty && state.tempatProses.trim().isNotEmpty;
      case 3:
        return state.alamatProduksi.trim().isNotEmpty;
      case 4:
        return state.setujuPernyataan;
      default:
        return false;
    }
  }

  void nextStep() {
    if (validateCurrentStep() && state.currentStep < 4) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
      saveProgress();
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
      saveProgress();
    }
  }

  Future<void> resetWizard() async {
    emit(const HalalWizardState());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
