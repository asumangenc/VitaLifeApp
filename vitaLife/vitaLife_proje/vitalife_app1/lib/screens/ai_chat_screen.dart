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

  // Öneri soruları
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

  // SENİN ASIL ÇALIŞAN FONKSİYONUN (HİÇ DOKUNMADIM)
  void _sendMessage() async {
    String userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": userText});
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
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
          _messages.add({"role": "bot", "text": "Üzgünüm, şu an bağlantı kuramıyorum. Lütfen Python sunucusunu kontrol et."});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  // ÖNERİ KARTLARI İÇİN EKLEDİĞİM GÜVENLİ FONKSİYON
  void _sendSuggestion(String text) {
    _controller.text = text; // Karttaki yazıyı kutuya yaz
    _sendMessage(); // Senin çalışan fonksiyonunu tetikle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F8),
      appBar: AppBar(
        title: const Text("VitaLife AI Asistanı", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal, // HomeScreen ile uyumlu
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildChatList(),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

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
            const SizedBox(height: 15),
            Text("Merhaba ${widget.userData?['fullname'] ?? 'Kullanıcı'}!",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 20),
            // Öneri Kartları
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _suggestions.map((text) => ActionChip(
                label: Text(text),
                backgroundColor: Colors.white,
                labelStyle: const TextStyle(color: Colors.teal),
                onPressed: () => _sendSuggestion(text),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(15),
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isUser ? 15 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 15),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text("VitaLife asistanı yazıyor...",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.teal, fontSize: 12)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: "Mesajınızı yazın...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: Colors.orange,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}