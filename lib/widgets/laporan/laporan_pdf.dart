import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../models/laporan_models.dart';
import '../../models/app_constants.dart';

class LaporanPdfExport {
  static final _formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static Future<void> exportToPDF(
      BuildContext context, LaporanData laporanData) async {
    try {
      final pdf = pw.Document();
      final lahan = laporanData.lahan;
      final perawatan = laporanData.perawatan.data;
      final panen = laporanData.panen.data;
      final summary = laporanData.summary;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            // Header
            _buildPdfHeader(lahan),
            pw.SizedBox(height: 20),

            // Informasi Lahan
            _buildPdfLahanInfo(lahan, laporanData.periode),
            pw.SizedBox(height: 20),

            // Ringkasan Keuangan
            _buildPdfSummary(summary),
            pw.SizedBox(height: 25),

            // Data Perawatan
            _buildPdfPerawatanTable(
                perawatan, laporanData.perawatan.totalBiaya),
            pw.SizedBox(height: 25),

            // Data Panen
            _buildPdfPanenTable(panen, laporanData.panen),
            pw.SizedBox(height: 20),

            // Footer
            _buildPdfFooter(laporanData.metadata),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            'Laporan_${lahan.nama}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF berhasil dibuat'),
          backgroundColor: Color(AppColors.successGreen),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat PDF: $e'),
          backgroundColor: const Color(AppColors.errorRed),
        ),
      );
    }
  }

  static pw.Widget _buildPdfHeader(LahanLaporan lahan) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        children: [
          pw.Text(
            'LAPORAN LAHAN',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            lahan.nama,
            style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
          ),
          pw.Divider(thickness: 2),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfLahanInfo(
      LahanLaporan lahan, PeriodeLaporan periode) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Informasi Lahan',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _buildPdfInfoRow('Nama', lahan.nama),
          _buildPdfInfoRow('Lokasi', lahan.lokasi),
          _buildPdfInfoRow('Luas', lahan.luas),
          _buildPdfInfoRow('Titik Tanam', '${lahan.titikTanam} titik'),
          _buildPdfInfoRow('Status', lahan.statusKepemilikan),
          if (periode.tanggalDari != null)
            _buildPdfInfoRow(
              'Periode',
              '${_formatDateForPdf(periode.tanggalDari!)} - ${_formatDateForPdf(periode.tanggalSampai!)}',
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfSummary(SummaryLaporan summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'RINGKASAN KEUANGAN',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          _buildPdfSummaryRow(
              'Total Biaya Perawatan', summary.totalBiayaPerawatan),
          _buildPdfSummaryRow(
              'Total Pendapatan Panen', summary.totalPendapatan),
          pw.Divider(thickness: 2),
          _buildPdfSummaryRow(
            summary.isUntung ? 'KEUNTUNGAN' : 'KERUGIAN',
            summary.totalKeuntungan,
            isTotal: true,
            color: summary.isUntung ? PdfColors.green : PdfColors.red,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'ROI: ${summary.persentaseKeuntungan.toStringAsFixed(1)}%',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfPerawatanTable(
      List<PerawatanLaporanItem> perawatan, int totalBiaya) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Data Perawatan (${perawatan.length} kegiatan)',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        if (perawatan.isEmpty)
          pw.Text('Belum ada data perawatan',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic))
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildPdfTableCell('Tanggal', isHeader: true),
                  _buildPdfTableCell('Kegiatan', isHeader: true),
                  _buildPdfTableCell('Jumlah', isHeader: true),
                  _buildPdfTableCell('Biaya', isHeader: true),
                ],
              ),
              // Data
              ...perawatan.map((item) => pw.TableRow(
                    children: [
                      _buildPdfTableCell(_formatDateForPdf(item.tanggal)),
                      _buildPdfTableCell(item.kegiatan,
                          align: pw.Alignment.centerLeft),
                      _buildPdfTableCell('${item.jumlah}'),
                      _buildPdfTableCell(_formatCurrency.format(item.biaya),
                          align: pw.Alignment.centerRight),
                    ],
                  )),
              // Total
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildPdfTableCell('TOTAL', isHeader: true),
                  pw.Container(),
                  pw.Container(),
                  _buildPdfTableCell(
                    _formatCurrency.format(totalBiaya),
                    isHeader: true,
                    align: pw.Alignment.centerRight,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildPdfPanenTable(
      List<PanenLaporanItem> panen, PanenLaporan panenLaporan) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Data Panen (${panen.length} kali panen)',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        if (panen.isEmpty)
          pw.Text('Belum ada data panen',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic))
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildPdfTableCell('Tanggal', isHeader: true),
                  _buildPdfTableCell('Jumlah (kg)', isHeader: true),
                  _buildPdfTableCell('Harga/kg', isHeader: true),
                  _buildPdfTableCell('Total', isHeader: true),
                ],
              ),
              // Data
              ...panen.map((item) => pw.TableRow(
                    children: [
                      _buildPdfTableCell(_formatDateForPdf(item.tanggal)),
                      _buildPdfTableCell('${item.jumlah}'),
                      _buildPdfTableCell(_formatCurrency.format(item.harga),
                          align: pw.Alignment.centerRight),
                      _buildPdfTableCell(_formatCurrency.format(item.total),
                          align: pw.Alignment.centerRight),
                    ],
                  )),
              // Total
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildPdfTableCell('TOTAL', isHeader: true),
                  _buildPdfTableCell('${panenLaporan.totalJumlahKg} kg',
                      isHeader: true),
                  pw.Container(),
                  _buildPdfTableCell(
                    _formatCurrency.format(panenLaporan.totalPendapatan),
                    isHeader: true,
                    align: pw.Alignment.centerRight,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildPdfFooter(MetadataLaporan metadata) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Divider(),
          pw.Text(
            'Dicetak pada: ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
          ),
          pw.Text(
            'Oleh: ${metadata.userName}',
            style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // Helper methods
  static pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(label,
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          ),
          pw.Text(': ', style: pw.TextStyle(fontSize: 10)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfSummaryRow(String label, int value,
      {bool isTotal = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 13 : 11,
              color: color,
            ),
          ),
          pw.Text(
            _formatCurrency.format(value),
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 13 : 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfTableCell(String text,
      {bool isHeader = false, pw.Alignment? align}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: align ?? pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 10 : 9,
        ),
      ),
    );
  }

  static String _formatDateForPdf(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
