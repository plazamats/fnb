import '../models/app_language.dart';
import '../models/transaction_model.dart';

class VoiceInterpretationResult {
  const VoiceInterpretationResult({
    required this.transcript,
    required this.detectedType,
    required this.amount,
    required this.productName,
    required this.quantity,
    required this.isConfident,
    required this.needsUserConfirmation,
    required this.explanation,
  });

  final String transcript;
  final TransactionType detectedType;
  final double? amount;
  final String? productName;
  final int quantity;
  final bool isConfident;
  final bool needsUserConfirmation;
  final String explanation;
}

class VoiceNlpService {
  /// Interprets voice utterances across 6 South African languages:
  /// isiZulu, Sesotho, siSwati, isiXhosa, Afrikaans, and English.
  static VoiceInterpretationResult interpret({
    required String speechText,
    required AppLanguage language,
  }) {
    final text = speechText.trim();
    final lower = text.toLowerCase();

    // 1. Detect Amount (e.g., "R90", "R 100", "90 rand", "150")
    double? detectedAmount;
    final rMatch = RegExp(r'[rR]\s*(\d+(?:\.\d{1,2})?)').firstMatch(text);
    if (rMatch != null) {
      detectedAmount = double.tryParse(rMatch.group(1)!);
    } else {
      final randMatch = RegExp(r'(\d+(?:\.\d{1,2})?)\s*(?:rand|rands|amashumi)', caseSensitive: false).firstMatch(text);
      if (randMatch != null) {
        detectedAmount = double.tryParse(randMatch.group(1)!);
      }
    }

    // 2. Detect Quantity (e.g. "5", "amahlanu", "tse tharo", "2")
    int detectedQuantity = 1;
    final qtyNumberMatch = RegExp(r'\b(\d+)\b').firstMatch(lower);
    if (qtyNumberMatch != null && detectedAmount != null && qtyNumberMatch.group(1) != detectedAmount.toInt().toString()) {
      detectedQuantity = int.tryParse(qtyNumberMatch.group(1)!) ?? 1;
    } else if (lower.contains('amahlanu') || lower.contains('hlano') || lower.contains('five') || lower.contains('vyf')) {
      detectedQuantity = 5;
    } else if (lower.contains('amabili') || lower.contains('pedi') || lower.contains('two') || lower.contains('twee') || lower.contains('ezimbini')) {
      detectedQuantity = 2;
    } else if (lower.contains('amathathu') || lower.contains('tharo') || lower.contains('three') || lower.contains('drie') || lower.contains('ezintathu')) {
      detectedQuantity = 3;
    } else if (lower.contains('amane') || lower.contains('nne') || lower.contains('four') || lower.contains('vier')) {
      detectedQuantity = 4;
    }

    // 3. Detect Transaction Type
    TransactionType detectedType = TransactionType.sale;
    bool confident = true;
    bool needsConfirm = false;

    // Till draws / personal family draws
    if (lower.contains('till') ||
        lower.contains('tsere') ||
        lower.contains('khiphe') ||
        lower.contains('draw') ||
        lower.contains('omndeni') ||
        lower.contains('lelapa') ||
        lower.contains('huiskas')) {
      detectedType = TransactionType.tillDraw;
    }
    // Stock delivery / purchase from supplier
    else if (lower.contains('stock') ||
        lower.contains('isitoko') ||
        lower.contains('thepa') ||
        lower.contains('voorraad') ||
        lower.contains('invoice') ||
        lower.contains('deliver') ||
        lower.contains('thwalise') ||
        lower.contains('ibhokisi') ||
        lower.contains('reka thepa') ||
        lower.contains('thenga isitoko')) {
      detectedType = TransactionType.stockArrival;
    }
    // General shop expense (electricity, transport, plastic bags)
    else if (lower.contains('expense') ||
        lower.contains('izindleko') ||
        lower.contains('ditshenyehelo') ||
        lower.contains('iindleko') ||
        lower.contains('uitgawe') ||
        lower.contains('gesi') ||
        lower.contains('electricity') ||
        lower.contains('petrol') ||
        lower.contains('transport')) {
      detectedType = TransactionType.expense;
    }
    // Sales
    else if (lower.contains('thengise') ||
        lower.contains('reka') ||
        lower.contains('rekisitse') ||
        lower.contains('sale') ||
        lower.contains('sold') ||
        lower.contains('verkoop') ||
        lower.contains('kutsengisa')) {
      detectedType = TransactionType.sale;
    } else {
      // Ambiguous: requires explicit confirmation
      confident = false;
      needsConfirm = true;
      detectedType = TransactionType.sale;
    }

    // 4. Product Name Detection
    String? detectedProduct;
    if (lower.contains('qanda') || lower.contains('mae') || lower.contains('egg') || lower.contains('eier')) {
      detectedProduct = 'Eggs';
    } else if (lower.contains('sinkwa') || lower.contains('bohobe') || lower.contains('bread') || lower.contains('brood')) {
      detectedProduct = 'Brown Bread';
    } else if (lower.contains('bisi') || lower.contains('lebese') || lower.contains('milk') || lower.contains('melk')) {
      detectedProduct = 'Milk 1L';
    } else if (lower.contains('savanna')) {
      detectedProduct = 'Savanna Cider';
    } else if (lower.contains('black label') || lower.contains('carling')) {
      detectedProduct = 'Carling Black Label';
    } else if (lower.contains('castle')) {
      detectedProduct = 'Castle Lager';
    } else if (lower.contains('amstel')) {
      detectedProduct = 'Amstel Lager';
    } else if (lower.contains('coca') || lower.contains('coke') || lower.contains('drink')) {
      detectedProduct = 'Cold Drinks 2L';
    } else if (lower.contains('oil') || lower.contains('oli')) {
      detectedProduct = 'Cooking Oil 750ml';
    } else if (detectedType == TransactionType.tillDraw) {
      detectedProduct = 'Personal / Family Cash Draw';
    } else if (detectedType == TransactionType.expense) {
      detectedProduct = 'General Shop Expense';
    }

    if (detectedAmount == null) {
      needsConfirm = true;
      confident = false;
    }

    return VoiceInterpretationResult(
      transcript: text,
      detectedType: detectedType,
      amount: detectedAmount,
      productName: detectedProduct,
      quantity: detectedQuantity,
      isConfident: confident,
      needsUserConfirmation: needsConfirm,
      explanation: confident
          ? 'Clear ${detectedType.label} recognized'
          : 'Please review and confirm missing values before saving',
    );
  }

  /// Preset sample phrases across the 6 supported languages for one-tap simulation in the demo/testing:
  static List<({String phrase, AppLanguage lang, String description})> get presetPhrases => [
    (
      phrase: 'Ngi-thengise amaqanda amahlanu ngo-R90.',
      lang: AppLanguage.isizulu,
      description: 'isiZulu: Sale of 5 eggs for R90',
    ),
    (
      phrase: 'Ke tsere R100 mo tilleng.',
      lang: AppLanguage.sesotho,
      description: 'Sesotho: Family till draw of R100',
    ),
    (
      phrase: 'Ngitsengise tibhontshisi netinkwa nge-R75.',
      lang: AppLanguage.siswati,
      description: 'siSwati: Sale of beans & bread for R75',
    ),
    (
      phrase: 'Ndithwalise iibhokisi zobisi ezimbini ngo-R140.',
      lang: AppLanguage.isixhosa,
      description: 'isiXhosa: Stock delivery of 2 milk crates for R140',
    ),
    (
      phrase: 'Ek het 2 kiste Castle Lager verkoop vir R240.',
      lang: AppLanguage.afrikaans,
      description: 'Afrikaans: Sold 2 Castle 6-packs for R240',
    ),
    (
      phrase: 'Sold 3 cold drinks and 2 brown bread for R110.',
      lang: AppLanguage.english,
      description: 'English: Sale of drinks and bread for R110',
    ),
  ];
}
