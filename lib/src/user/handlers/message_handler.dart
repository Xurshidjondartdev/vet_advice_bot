import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:vet_advice_bot/core/constants.dart';
import 'package:vet_advice_bot/src/admin/handlers_admin/message_handler_admin.dart';
import 'package:vet_advice_bot/src/services/database_service.dart';

import '../../buttons/buttons.dart';
import '../../services/io_service.dart';
import 'common_handler.dart';

class MessageHandler extends DatabaseService with Buttons, CommonHandler {
  final TeleDart bot;
  MessageHandler(this.bot);

  final List<String> states = ["Ratsion", "Retsept", "Parvarish uchun tavsiyalar", "Diagnostika", "Adminga murojat"];
  final List<String> events = [
    "🌽 Ratsion",
    "📝 Retsept",
    "📋 Parvarish uchun tavsiyalar",
    "🔍 Diagnostika",
    "📚 Qo'llanma",
    "💰 Balans",
    "💳 To'lov",
    "📊 Obunachilar soni",
    "🟢 Active obunachilar soni"
  ];

  Future<void> init() async {
    final MessageHandlerAdmin messageHandlerAdmin = MessageHandlerAdmin(bot);

    bot.onMessage().listen((event) async {
      if(event.from == null) return;
      final String? state;

      try {
        state = await getState(event.from!.id);
      } catch(e) {
        IO.red(e);
        await connectionException(bot, event.from!.id);
        return;
      }

      if(state == "receipt") {
        if(event.photo != null && event.photo!.isNotEmpty) {

          try {
            await updateState(null, event.from!.id);
          } finally {}

          await handleReceipt(event);
        } else {
          await event.reply(
            "❗️ To'lovni tasdiqlash uchun faqatgina rasm qabul qilinadi. Iltomos qaytadan urinib ko'ring.",
            replyMarkup: cancelSendingReceiptButton
          );
        }
      } else if(states.contains(state) && !events.contains(event.text)) {
        if(await subscribersIsActive(event.from!.id) || state == "Adminga murojat") {
          await handleMessage(event, state);
          IO.cyan("${event.from?.firstName}. 📨 Adminga murojat: ${event.text}");
        } else {
          await unauthorized(event);

          try {
            await updateState(null, event.from!.id);
          } finally {}
        }
      } else {
        if(!(event.from!.id == Constants.adminId && RegExp(r"^awaitingPaymentAmount \d+$").hasMatch(state??""))) {
          try {
            await updateState(null, event.from!.id);
          } finally {}
        }

        await handleDefaultMessage(event, state, messageHandlerAdmin);
      }
    });
  }


  /// handle

  Future<void> handleMessage(TeleDartMessage event, String? state) async {
    final Message message = await bot.sendMessage(
      event.from!.id,
      state == "Adminga murojat"
          ? "✅ Murojaatingiz qabul qilindi."
          : "✅ Xabaringiz mutahasisga yuborildi, iltimos javob qaytishini kuting ⏳ ...",
      replyToMessageId: event.messageId,
      parseMode: "html"
    );

    if(event.text != null && event.text!.trim().isNotEmpty) {
      await handleText(event, state);
    } else if(event.photo != null && event.photo!.isNotEmpty) {
      await handlePhoto(event, state);
    } else if(event.voice != null) {
      await handleVoice(event, state);
    } else if(event.videoNote != null) {
      await handleVideoNote(event, state);
    } else if(event.video != null) {
      await handleVideo(event, state);
    } else if(event.audio != null) {
      await handleAudio(event, state);
    } else if(event.sticker != null) {
      await handleSticker(event, state);
    } else {
      await bot.deleteMessage(event.chat.id, message.messageId);
      await bot.sendMessage(
        event.from!.id,
        "❌ Unknown ❗️\nXabaringiz yuborilmadi. Sababi: xabar type aniqlanmadi.",
        replyToMessageId: event.messageId,
        parseMode: "html"
      );
    }
  }

  Future<void> handleText(TeleDartMessage event, String? state) async {
    await bot.sendMessage(
      Constants.adminId,
      "🆔 #id_${event.from?.id}\n"
      "📝 <b>MessageId:</b> ${event.messageId}\n"
      "👤 <b>Firstname:</b> ${event.from?.firstName}\n"
      "💼 <b>Username:</b> @${event.from?.username}\n"
      "📂 <b>Category:</b> $state\n\n"
      "✉️ ${event.text?.trim()}",
      parseMode: "html",
    );

    IO.blue("Text");
  }

  Future<void> handlePhoto(TeleDartMessage event, String? state) async {
    await bot.sendPhoto(
      Constants.adminId,
      event.photo!.first.fileId,
      caption: "🆔 #id_${event.from?.id}\n"
          "📝 <b>MessageId:</b> ${event.messageId}\n"
          "👤 <b>Firstname:</b> ${event.from?.firstName}\n"
          "💼 <b>Username:</b> @${event.from?.username}\n"
          "📂 <b>Category:</b> $state"
          "${event.caption != null ? "\n\n${"✉️ ${event.caption}"}" : ""}",
      parseMode: "html",
    );

    IO.blue("Photo");
  }

  Future<void> handleVoice(TeleDartMessage event, String? state) async {
    await bot.sendVoice(
      Constants.adminId,
      event.voice?.fileId,
      caption: "🆔 #id_${event.from?.id}\n"
          "📝 <b>MessageId:</b> ${event.messageId}\n"
          "👤 <b>Firstname:</b> ${event.from?.firstName}\n"
          "💼 <b>Username:</b> @${event.from?.username}\n"
          "📂 <b>Category:</b> $state"
          "${event.caption != null ? "\n\n${"✉️ ${event.caption}"}" : ""}",
      parseMode: "html",
    );

    IO.blue("Voice");
  }

  Future<void> handleVideoNote(TeleDartMessage event, String? state) async {
    final Message message = await bot.sendMessage(
      Constants.adminId,
      "🆔 #id_${event.from?.id}\n"
      "📝 <b>MessageId:</b> ${event.messageId}\n"
      "👤 <b>Firstname:</b> ${event.from?.firstName}\n"
      "💼 <b>Username:</b> @${event.from?.username}\n"
      "📂 <b>Category:</b> $state\n\n"
      "Video Note ⬇️",
      parseMode: "html",
    );

    await bot.sendVideoNote(
      Constants.adminId,
      event.videoNote?.fileId,
      replyToMessageId: message.messageId
    );

    IO.blue("Video Note");
  }

  Future<void> handleVideo(TeleDartMessage event, String? state) async {
    await bot.sendVideo(
      Constants.adminId,
      event.video?.fileId,
      caption: "🆔 #id_${event.from?.id}\n"
          "📝 <b>MessageId:</b> ${event.messageId}\n"
          "👤 <b>Firstname:</b> ${event.from?.firstName}\n"
          "💼 <b>Username:</b> @${event.from?.username}\n"
          "📂 <b>Category:</b> $state"
          "${event.caption != null ? "\n\n${"✉️ ${event.caption}"}" : ""}",
      parseMode: "html",
    );

    IO.blue("Video");
  }

  Future<void> handleAudio(TeleDartMessage event, String? state) async {
    await bot.sendAudio(
      Constants.adminId,
      event.audio?.fileId,
      caption: "🆔 #id_${event.from?.id}\n"
          "📝 <b>MessageId:</b> ${event.messageId}\n"
          "👤 <b>Firstname:</b> ${event.from?.firstName}\n"
          "💼 <b>Username:</b> @${event.from?.username}\n"
          "📂 <b>Category:</b> $state"
          "${event.caption != null ? "\n\n${"✉️ ${event.caption}"}" : ""}",
      parseMode: "html",
    );

    IO.blue("Audio");
  }
  
  Future<void> handleSticker(TeleDartMessage event, String? state) async {
    final Message message = await bot.sendMessage(
      Constants.adminId,
      "🆔 #id_${event.from?.id}\n"
      "📝 <b>MessageId:</b> ${event.messageId}\n"
      "👤 <b>Firstname:</b> ${event.from?.firstName}\n"
      "💼 <b>Username:</b> @${event.from?.username}\n"
      "📂 <b>Category:</b> $state\n\n"
      "Sticker ⬇️",
      parseMode: "html",
    );

    await bot.sendSticker(
      Constants.adminId,
      event.sticker?.fileId,
      replyToMessageId: message.messageId
    );

    IO.blue("Sticker");
  }

  Future<void> handleReceipt(TeleDartMessage event) async {
    final PhotoSize photo = event.photo!.first;
    final String fileId = photo.fileId;
    final String userMessage = event.caption != null ? "✉️ <b>Foydalanuvchi xabari:</b> ${event.caption}\n\n" : "\n";

    await bot.sendMessage(
      event.from?.id,
      "Adminga yuborildi. To'lovingizni tasdiqlaganigan so'ng hisobingizga qo'shiladi.",
      replyToMessageId: event.messageId
    );

    await bot.sendPhoto(
      Constants.adminId,
      fileId,
      parseMode: "html",
      replyMarkup: approvalButtons,
      caption: "🆔 #id_${event.from!.id}\n"
          "👤 <b>Firstname:</b> ${event.from!.firstName}\n"
          "💼 <b>Username:</b> @${event.from!.username}\n"
          "$userMessage"
          "Ushbu foydalanuvchining to'lovi qabul qilinsinmi?",
    );
  }

  Future<void> handleDefaultMessage(TeleDartMessage event, String? state, MessageHandlerAdmin messageHandlerAdmin) async {
    switch(event.text) {
      case "🌽 Ratsion":
        await diet(event);
        break;
      case "📝 Retsept":
        await recipe(event);
        break;
      case "📋 Parvarish uchun tavsiyalar":
        await careRecommendations(event);
        break;
      case "🔍 Diagnostika":
        await diagnostics(event);
        break;
      case "📚 Qo'llanma":
        await guide(event);
        break;
      case "💰 Balans":
        await balance(event);
        break;
      case "💳 To'lov":
        await payment(bot, event.from!.id);
        break;
      default:
        await messageHandlerAdmin.onMessage(event, state);
        break;
    }
  }




  /// others

  Future<void> unauthorized(TeleDartMessage event) async {
    await bot.sendMessage(
      event.from!.id,
      "❌ Obuna sizda mavjud emas. Ushbu funksiyadan foydalanish uchun obunani yoqishingiz kerak.",
      replyToMessageId: event.messageId,
      replyMarkup: enableSubscriptionButton
    );
  }

  Future<void> diet(TeleDartMessage event) async {
    await event.reply(
      "<b>Ratsion</b> haqidagi savolingizni yozib qoldiring...",
      parseMode: "html"
    );

    try {
      await updateState("Ratsion", event.from!.id);
      IO.green("${event.from?.firstName}: updateState => Ratsion");
    } catch(e) {
      await connectionException(bot, event.from!.id);
      IO.red("${event.from?.firstName}: updateState => Ratsion ============== failed, $e");
    }
  }

  Future<void> recipe(TeleDartMessage event) async {
    await event.reply(
      "<b>Retsept</b> haqidagi savolingizni yozib qoldiring...",
      parseMode: "html"
    );

    try {
      await updateState("Retsept", event.from!.id);
      IO.green("${event.from?.firstName}: updateState => Retsept");
    } catch(e) {
      await connectionException(bot, event.from!.id);
      IO.red("${event.from?.firstName}: updateState => Retsept ============== failed, $e");
    }
  }

  Future<void> careRecommendations(TeleDartMessage event) async {
    await event.reply(
      "<b>Parvarish uchun tavsiyalar</b> haqidagi savolingizni yozib qoldiring...",
      parseMode: "html"
    );

    try {
      await updateState("Parvarish uchun tavsiyalar", event.from!.id);
      IO.green("${event.from?.firstName}: updateState => Parvarish uchun tavsiyalar");
    } catch(e) {
      await connectionException(bot, event.from!.id);
      IO.red("${event.from?.firstName}: updateState => Parvarish uchun tavsiyalar ============== failed, $e");
    }
  }

  Future<void> diagnostics(TeleDartMessage event) async {
    await event.reply(
      "<b>Diagnostika</b> haqidagi savolingizni yozib qoldiring...",
        parseMode: "html"
    );

    await updateState("Diagnostika", event.from!.id);

    try {
      await updateState("Diagnostika", event.from!.id);
      IO.green("${event.from?.firstName}: updateState => Diagnostika");
    } catch(e) {
      await connectionException(bot, event.from!.id);
      IO.red("${event.from?.firstName}: updateState => Diagnostika ============== failed, $e");
    }
  }

  Future<void> guide(TeleDartMessage event) async {
    await event.reply(
      "📚 <b>Qo'llanma:</b>\n"
          "Bu botdan qanday foydalanish haqida qo'llanma va tavsiyalar:\n\n"
          "1. Botning barcha imkoniyatlari bilan tanishish uchun /help komandasi orqali yordam oynasini oching.\n"
          "2. Obunani qanday yoqish va undan qanday foydalanishni bilish uchun /enablesubscription komandasi orqali qo'shimcha ma'lumot oling.\n"
          "3. Botda qanday xizmatlar mavjudligini bilish uchun asosiy menyuda tegishli tugmalarni tanlang.\n\n"
          "Agar sizda boshqa savollar bo'lsa, adminga murojaat qiling /appealtoadmin.",
      parseMode: "html",
    );

    IO.blue("📚 Qo'llanma");
  }

  Future<void> balance(TeleDartMessage event) async {
    final int balance = await getBalance(event.from!.id);
    await event.reply(
      "💳 <b>Sizning balansingiz:</b>       \n$balance UZS",
      parseMode: "html",
      replyMarkup: topUpAccountButton
    );

    IO.green("${event.from?.firstName}: balance => $balance");
  }
}
