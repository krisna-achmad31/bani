import 'package:bani/l10n/l10n.dart';
import 'dart:io';

import 'package:bani/core/utils/formatters.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ExcelExportService — members in depth-first order → .xlsx → share sheet
// ─────────────────────────────────────────────────────────────────────────────

class ExcelExportService {
  ExcelExportService._();

  static Future<void> export(String familyName, FamilyIndex index) async {
    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet() ?? 'Sheet1'];
    final t = tr;
    final headers = [
      t.xlsGeneration, t.xlsFullName, t.xlsNickname, t.xlsGender, t.xlsBirthOrder,
      t.xlsParent, t.xlsBirthPlace, t.xlsBirthDate, t.xlsStatus, t.xlsDeathDate,
      t.xlsSpouse, t.xlsOccupation,
    ];
    sheet.appendRow(headers.map(TextCellValue.new).toList());

    for (final m in index.dfs()) {
      sheet.appendRow([
        IntCellValue(m.generation),
        TextCellValue('${'  ' * (m.generation - 1)}${m.fullName}'),
        TextCellValue(m.nickname ?? ''),
        TextCellValue(m.gender.label),
        TextCellValue(m.birthOrder?.toString() ?? ''),
        TextCellValue(index.parentOf(m)?.fullName ?? ''),
        TextCellValue(m.birthPlace ?? ''),
        TextCellValue(formatDate(m.birthDate, yearOnly: m.birthYearOnly)),
        TextCellValue(m.isDeceased ? t.deceased : t.alive),
        TextCellValue(formatDate(m.deathDate, yearOnly: m.deathYearOnly)),
        TextCellValue(m.spouses.map((s) => '${s.name} (${s.status.label})').join(', ')),
        TextCellValue(m.occupation ?? ''),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final safe = familyName.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    final file = File('${dir.path}/Silsilah_$safe.xlsx');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      text: t.xlsShareText(familyName),
    ));
  }
}
