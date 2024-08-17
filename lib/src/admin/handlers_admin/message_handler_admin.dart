import 'dart:async';

import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:vet_advice_bot/core/constants.dart';
import 'package:vet_advice_bot/src/buttons/buttons.dart';
import 'package:vet_advice_bot/src/services/database_service.dart';
import 'package:vet_advice_bot/src/services/io_service.dart';
import 'package:vet_advice_bot/src/user/handlers/common_handler.dart';

class MessageHandlerAdmin extends DatabaseService with Buttons, CommonHandler {
  final TeleDart bot;
  MessageHandlerAdmin(this.bot);

  Future<void> onMessage(TeleDartMessage event, String? state) async {
    if(event.from?.id != Constants.adminId) {
      await handleUnknownMessage(event);
      return;
    }

    if(RegExp(r"^awaitingPaymentAmount \d+$").hasMatch(state??"") && !["📊 Obunachilar soni", "🟢 Active obunachilar soni"].contains(event.text)) {
      final int id = int.parse(state!.split(" ").last);
      await processPaymentToBalance(event, id);
    } else if(event.replyToMessage != null) {
      await handleAdminReply(event);
    } else {
      switch(event.text) {
        case "📊 Obunachilar soni":
          await $subscribers(event);
          break;
        case "🟢 Active obunachilar soni":
          await $activeSubscribers(event);
          break;
        default:
          await handleUnknownMessage(event);
      }
    }
  }

  Future<void> handleAdminReply(TeleDartMessage event) async {
    try {
      final int? chatId = int.tryParse((event.replyToMessage?.text ?? (event.replyToMessage?.caption ?? "")).split("\n").first.trim().substring(7));
      final int? messageId = int.tryParse((event.replyToMessage?.text ?? (event.replyToMessage?.caption ?? "")).split("\n")[1].trim().substring(13));
      await deleteMessageIfExists(chatId, messageId);
      await sendMessage(chatId, messageId, event);
      await event.reply("✅ Xabar muvofaqiyatli yuborildi.");
    } catch(e) {
      await event.reply("❌ Xabar hechkimga yuborilmadi.");
    }
  }

  Future<void> handleUnknownMessage(TeleDartMessage event) async {
    await bot.sendMessage(
      event.from?.id,
      "❗️ Xabar maqsadi aniqlanmadi, iltimos botga to'g'ridan to'g'ri xabar yubormang.",
      replyToMessageId: event.messageId
    );
  }


  /// send message

  Future<void> sendMessage(int? chatId, int? messageId, TeleDartMessage event) async {
    if(event.text != null && event.text!.trim().isNotEmpty) {
      await bot.sendMessage(chatId, event.text.toString(), replyToMessageId: messageId);
    } else if(event.photo != null && event.photo!.isNotEmpty) {
      await bot.sendPhoto(chatId, event.photo!.first.fileId, caption: event.caption, replyToMessageId: messageId);
    } else if(event.voice != null) {
      await bot.sendVoice(chatId, event.voice!.fileId, caption: event.caption, replyToMessageId: messageId);
    } else if(event.videoNote != null) {
      await bot.sendVideoNote(chatId, event.videoNote!.fileId, replyToMessageId: messageId);
    } else if(event.video != null) {
      await bot.sendVideo(chatId, event.video!.fileId, caption: event.caption, replyToMessageId: messageId);
    } else if(event.audio != null) {
      await bot.sendAudio(chatId, event.audio!.fileId, caption: event.caption, replyToMessageId: messageId);
    } else if(event.sticker != null) {
      await bot.sendSticker(chatId, event.sticker!.fileId, replyToMessageId: messageId);
    } else {
      await bot.sendMessage(
        event.from!.id,
        "❌ Unknown ❗️\nXabaringiz yuborilmadi. Sababi: xabar type aniqlanmadi.",
        replyToMessageId: event.messageId,
        parseMode: "html"
      );
    }
  }

  Future<void> deleteMessageIfExists(int? chatId, int? messageId) async {
    try {
      await bot.deleteMessage(chatId, messageId! + 1);
    } catch(e){
      return;
    }
  }

  Future<void> processPaymentToBalance(TeleDartMessage event, int id) async {
    final int? paymentAmount = int.tryParse(event.text.toString());

    if(paymentAmount != null) {
      await event.reply("⏳");

      try {
        await updateUserBalance(id, int.parse(event.text??"0"));
        await bot.sendMessage(id, "✅ Balansingizga ${event.text} UZS qabul qilindi.");
        final String userInfo = await getUserInfo(id);
        await bot.deleteMessage(event.from?.id, event.messageId+1);
        await event.reply("$userInfo✅ To'lov muvofaqiyatli amalga oshirildi.", parseMode: "html");
        await updateState(null, event.from!.id);
      } catch(e) {
        await bot.sendMessage(
          event.from?.id,
          "❌ To'lov miqdori qabul qilinmadi. To'luv summasi limitdan oshib ketdi, iltimos qaytadan kiriting...",
          replyToMessageId: event.messageId,
          replyMarkup: cancellationPaymentButton
        );
      }
    } else {
      await bot.sendMessage(
        event.from?.id,
        "❌ To'lov miqdori qabul qilinmadi, iltimos raqam kiriting...",
        replyToMessageId: event.messageId,
        replyMarkup: cancellationPaymentButton
      );
    }
  }

  Future<void> $subscribers(TeleDartMessage event) async {
    try {
      final int subscribersCount = await subscribers();
      final String botName = (await bot.getMe()).firstName;

      await event.reply(
        "<b>$botName</b>'ning obunachilari soni <b>$subscribersCount</b> ga teng.",
        parseMode: "html"
      );

      IO.green("${event.from?.firstName}: show subscribers count => $subscribersCount");
    } catch(e) {
      await connectionException(bot, event.from!.id);
      IO.red("${event.from?.firstName}: show subscribers count => failed, $e");
    }
  }

  Future<void> $activeSubscribers(TeleDartMessage event) async {
    try {
      final int activeSubscribersCount = await activeSubscribers();
      final String botName = (await bot.getMe()).firstName;

      await event.reply(
        "<b>$botName</b>'ning active obunachilari soni <b>$activeSubscribersCount</b> ga teng.",
        parseMode: "html"
      );

      IO.green("${event.from?.firstName}: show subscribers count => $activeSubscribersCount");
    } catch(e) {
      await connectionException(bot, event.from!.id);
      IO.red("${event.from?.firstName}: show active subscribers count => failed, $e");
    }
  }
}
