import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:vet_advice_bot/src/services/database_service.dart';
import 'package:vet_advice_bot/src/user/handlers/common_handler.dart';

import '../../buttons/buttons.dart';
import '../../services/io_service.dart';

class QueryHandlerAdmin extends DatabaseService with Buttons, CommonHandler {
  final TeleDart bot;
  QueryHandlerAdmin(this.bot);

  Future<void> onCallbackQuery(TeleDartCallbackQuery query) async {
    switch(query.data) {
      case "approvePayment":
        await approvePayment(query);
        break;
      case "rejectPayment":
        await rejectPayment(query);
        break;
      case "addPayment":
        await addPayment(query);
        break;
      case "cancellationPayment":
        await cancellationPayment(query);
        break;
    }
  }

  Future<void> addPayment(TeleDartCallbackQuery query) async {
    try {
      final int userId = int.parse(query.message!.caption!.split("\n").first.substring(7).trim());
      await bot.sendMessage(query.from.id, "Pul miqdorini kiriting...");
      await updateState("awaitingPaymentAmount $userId", query.from.id);

      IO.blue("${query.from.firstName}: updateState => \"awaitingPaymentAmount $userId\"");
    } catch(e) {
      await connectionException(bot, query.from.id);
      IO.blue("${query.from.firstName}: updateState => failed");
    }
  }

  Future<void> cancellationPayment(TeleDartCallbackQuery query) async {
    try {
      await bot.sendMessage(query.from.id, "❌ To'lov bekor qilindi.");
      await updateState(null, query.from.id);
    } catch(e) {
      await connectionException(bot, query.from.id);
      IO.blue("${query.from.firstName}: updateState => failed");
    }
  }

  Future<void> approvePayment(TeleDartCallbackQuery query) async {
    await bot.editMessageReplyMarkup(
      chatId: query.from.id,
      messageId: query.message?.messageId,
      replyMarkup: addPaymentButton
    );

    try {
      final int userId = int.parse(query.message!.caption!.split("\n").first.substring(7).trim());
      await bot.sendMessage(query.from.id, "Pul miqdorini kiriting...");
      await updateState("awaitingPaymentAmount $userId", query.from.id);
    } catch(e) {
      await connectionException(bot, query.from.id);
      IO.blue("${query.from.firstName}: updateState => failed");
    }
  }

  Future<void> rejectPayment(TeleDartCallbackQuery query) async {
    try {
      final int userId = int.parse(query.message!.caption!.split("\n").first.substring(7).trim());
      await bot.sendMessage(userId, "To'lovingiz qabul qilinmadi.");

      await bot.editMessageReplyMarkup(
        chatId: query.from.id,
        messageId: query.message?.messageId,
        replyMarkup: addPaymentButton
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await query.answer(
        text: "To'lob qabul qilinmaganligi haqidagi malumot foydalanuvchiga yuborildi.",
        showAlert: true
      );
    } catch(e) {
      await bot.sendMessage(query.from.id, "Xatolik yuz berdi, iltomos qaytadan urinib ko'ring.");
    }
  }
}
