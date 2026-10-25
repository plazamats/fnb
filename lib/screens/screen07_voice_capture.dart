import 'package:flutter/material.dart';
import '../models/app_language.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../services/matrix_firestore_service.dart';
import '../services/voice_nlp_service.dart';
import '../widgets/fnb_brand_header.dart';
import '../widgets/transaction_confirm_dialog.dart';

class Screen07VoiceCapture extends StatefulWidget {
  const Screen07VoiceCapture({super.key});

  @override
  State<Screen07VoiceCapture> createState() => _Screen07VoiceCaptureState();
}

class _Screen07VoiceCaptureState extends State<Screen07VoiceCapture> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _pulseController;
  final TextEditingController _customTextCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _customTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);
    final lang = state.activeLanguage;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: fnbDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Capture Ledger',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: fnbDark),
            ),
            Text(
              'Language: ${lang.displayName} • ${state.activeShop.shortLabel}',
              style: const TextStyle(fontSize: 10, color: fnbTeal),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<AppLanguage>(
            tooltip: 'Switch Language',
            icon: const Icon(Icons.language, color: fnbDark),
            onSelected: (l) => state.setLanguage(l),
            itemBuilder: (ctx) => AppLanguage.values.map((l) {
              return PopupMenuItem(
                value: l,
                child: Row(
                  children: [
                    if (l == lang) const Icon(Icons.check, size: 16, color: fnbTeal) else const SizedBox(width: 16),
                    const SizedBox(width: 6),
                    Text(l.displayName),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xffe2eeee), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Speak naturally in your preferred language',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: fnbDark),
          ),
          const SizedBox(height: 6),
          Text(
            'Supports isiZulu, Sesotho, siSwati, isiXhosa, Afrikaans & English. Speak a sale, expense, stock delivery or till draw.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 24),

          // Hold to Speak Center Mic with Animated Pulse
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = _isListening ? 1.0 + (_pulseController.value * 0.15) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: _isListening ? const Color(0xff8ce1e5) : fnbPaleTeal,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: fnbTeal.withValues(alpha: _isListening ? 0.35 : 0.1),
                          blurRadius: _isListening ? 24 : 12,
                          spreadRadius: _isListening ? 6 : 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          setState(() => _isListening = !_isListening);
                          if (!_isListening) {
                            // Process default simulated phrase for current language
                            final defaultPhrase = VoiceNlpService.presetPhrases
                                .firstWhere(
                                  (p) => p.lang == lang,
                                  orElse: () => VoiceNlpService.presetPhrases.first,
                                )
                                .phrase;
                            _processUtterance(context, defaultPhrase, lang, state.activeShop.id);
                          }
                        },
                        child: Center(
                          child: Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            size: 48,
                            color: fnbTeal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              _isListening ? lang.listening : lang.holdToSpeak,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _isListening ? Colors.redAccent : fnbTeal,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Preset Voice Simulations (Tap to Test Multi-Language Engine)
          const Text(
            'TEST ONE-TAP VOICE EXAMPLES',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fnbTeal, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),

          for (final preset in VoiceNlpService.presetPhrases)
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              color: fnbSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: preset.lang == lang ? fnbTeal : const Color(0xffe2eeee),
                  width: preset.lang == lang ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.record_voice_over_outlined, color: fnbTeal, size: 20),
                ),
                title: Text(
                  '“${preset.phrase}”',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(preset.description, style: const TextStyle(fontSize: 9, color: Colors.black54)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: fnbTeal),
                onTap: () {
                  _processUtterance(context, preset.phrase, preset.lang, state.activeShop.id);
                },
              ),
            ),

          const SizedBox(height: 16),

          // Custom Input Box for Freeform Voice Simulation
          const Text(
            'OR TYPE A PHRASE TO INTERPRET',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fnbTeal, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customTextCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Ngi-thengise 2 sinkwa ngo R36',
                    hintStyle: const TextStyle(fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: fnbTeal),
                onPressed: () {
                  if (_customTextCtrl.text.trim().isNotEmpty) {
                    _processUtterance(context, _customTextCtrl.text.trim(), lang, state.activeShop.id);
                  }
                },
                child: const Text('Interpret'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _processUtterance(
    BuildContext context,
    String transcript,
    AppLanguage language,
    String businessId,
  ) async {
    final result = VoiceNlpService.interpret(speechText: transcript, language: language);

    // Prompt user confirmation modal (per specification: never silently save uncertain extractions!)
    final confirmedTx = await showDialog<MzansiTransaction>(
      context: context,
      builder: (ctx) => TransactionConfirmDialog(
        initialType: result.detectedType,
        initialAmount: result.amount,
        initialDescription: result.explanation,
        productName: result.productName,
        quantity: result.quantity,
        source: 'voice',
        rawTranscript: transcript,
      ),
    );

    if (confirmedTx != null && context.mounted) {
      final txToSave = MzansiTransaction(
        id: confirmedTx.id,
        type: confirmedTx.type,
        business: businessId,
        amount: confirmedTx.amount,
        description: confirmedTx.description,
        productName: confirmedTx.productName,
        quantity: confirmedTx.quantity,
        source: 'voice',
        languageCode: language.code,
        rawTranscript: transcript,
        timestamp: DateTime.now(),
      );

      await MatrixFirestoreService.recordTransaction(txToSave);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved: ${txToSave.type.label} of R ${txToSave.amount.toStringAsFixed(2)} confirmed.'),
            backgroundColor: fnbTeal,
          ),
        );
      }
    }
  }
}
