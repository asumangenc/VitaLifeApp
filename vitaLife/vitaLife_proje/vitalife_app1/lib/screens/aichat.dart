import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'api_service.dart';

class AIChatScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const AIChatScreen({super.key, this.userData});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  // Hızlı öneri kartları
  final List<String> _suggestions = [
    "Bugün ne yemeliyim? 🥗",
    "VKİ değerim ne demek? 📊",
    "Su içmenin önemi 💧",
    "Kilo vermek için tüyo 🏃",
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ESKİ KODDAKİ ÇALIŞAN MANTIK (Aynen korundu)
  void _sendMessage({String? customText}) async {
    String userText = customText ?? _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": userText});
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // Python API bağlantısı
      final response = await ApiService.askGemini(userText, widget.userData);

      if (mounted) {
        setState(() {
          _messages.add({"role": "bot", "text": response});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "bot",
            "text": "Üzgünüm, şu an bağlantı kuramıyorum. Lütfen Python sunucusunu kontrol et."
          });
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F8),
      appBar: AppBar(
        title: const Text("VitaLife AI Asistanı",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal, // HomeScreen ile uyumlu Teal
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : _buildChatList(),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  // Yeni Tasarım: Lottie ve Öneriler
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Lottie.network(
              'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json',
              height: 180,
              repeat: true,
            ),
            const SizedBox(height: 10),
            Text("Merhaba ${widget.userData?['fullname'] ?? 'Kullanıcı'}!",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                "Beslenme asistanın senin için burada. Başlamak için bir öneriye tıkla veya mesaj yaz:",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            _buildSuggestionGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: _suggestions.map((text) => InkWell(
          onTap: () => _sendMessage(customText: text),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.teal.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(color: Colors.teal.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Text(text, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        bool isUser = _messages[index]["role"] == "user";
        return _buildMessageBubble(_messages[index]["text"]!, isUser);
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 15, height: 15,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
          ),
          const SizedBox(width: 10),
          Text("VitaLife düşünüyor...", style: TextStyle(color: Colors.teal[700], fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send, // Klavyedeki gönder tuşunu aktif ettik
              onSubmitted: (_) => _sendMessage(),   // Klavyeden gönderilirse çalıştır
              decoration: InputDecoration(
                hintText: "Asistana bir şey sor...",
                filled: true,
                fillColor: const Color(0xFFF4F9F8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}