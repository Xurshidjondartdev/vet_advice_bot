import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:vet_advice_bot/src/admin/handlers_admin/query_handler_admin.dart';
import 'package:vet_advice_bot/src/services/database_service.dart';
import 'package:vet_advice_bot/src/services/io_service.dart';

import '../../../core/constants.dart';
import '../../buttons/buttons.dart';
import 'common_handler.dart';

class QueryHandler extends DatabaseService with Buttons, CommonHandler {
  /// Telegram bot instance
  final TeleDart bot;
  QueryHandler(this.bot);

  Future<void> init() async {
    final QueryHandlerAdmin queryHandlerAdmin = QueryHandlerAdmin(bot);

    bot.onCallbackQuery().listen((query) async {
      try {
        await updateState(null, query.from.id);
      } finally {}

      switch(query.data) {
        case "topUpAccount":
          await payment(bot, query.from.id);
          break;
        case "sendReceipt":
          await onSendReceiptButton(query);
          break;
        case "subscription":
          await subscription(bot, query.from.id);
          break;
        case "enableSubscription":
          await enableSubscription(bot, query.from.id);
          break;
        case "disableSubscription":
          await disableSubscription(bot, query.from.id);
          break;
        case "cancelSendingReceipt":
          await cancelSendingReceipt(query);
          break;
        case "appealToAdmin":
          await appealToAdmin(bot, query.from.id);
          break;
        default:
          await queryHandlerAdmin.onCallbackQuery(query);
      }
    });
  }

  Future<void> onSendReceiptButton(TeleDartCallbackQuery query) async {

    try {
      await updateState("receipt", query.from.id);
      IO.green("${query.from.firstName}: To'lovni tasdiqlovchi chek kutilmoqda");
    } catch(e) {
      IO.red("${query.from.firstName}: To'lovni tasdiqlovchi chek kutilmoqda => failed");
      await connectionException(bot, query.from.id);
      return;
    }

    await bot.sendMessage(query.from.id, "To'lovni tasdiqlovchi chek yoki screenshotni botga yuboring...");
  }

  Future<void> cancelSendingReceipt(TeleDartCallbackQuery query) async {
    try {
      await updateState(null, query.from.id);
      await bot.sendMessage(query.from.id, "Chekni yuborish bekor qilindi.");
      IO.blue("${query.from.firstName}: Chekni yuborish bekor qilindi.");
    } catch(e) {
      await connectionException(bot, query.from.id);
      IO.red("${query.from.firstName}: Chekni yuborishni bekor qilish => failed");
    }
  }

  Future<void> enableSubscription(TeleDart bot, int chatId) async {
    try {
      if(await subscribersIsActive(chatId)) {
        await bot.sendMessage(chatId, "✅ Sizda allaqachon obuna yoniq. ✅");
        IO.yellow("$chatId: ✅ Sizda allaqachon obuna yoniq. ✅");
      } else {
        if(Constants.subscriptionPrice <= await getBalance(chatId)) {
          final String subscriptionDuration = (Constants.subscriptionPeriod % 24 == 0)
              ? (Constants.subscriptionPeriod ~/ 24).toString()
              : (Constants.subscriptionPeriod / 24).toStringAsFixed(1);

          final Message message = await bot.sendMessage(chatId, "⏳");
          await updateUserBalance(chatId, -(Constants.subscriptionPrice));
          await updateLastPaymentDate(chatId);
          await bot.deleteMessage(chatId, message.messageId);
          await bot.sendMessage(chatId, "Hisobingizdan ${Constants.subscriptionPrice} UZS yechib olindi. To'lov maqsadi obuna sotib olish.");
          await bot.sendMessage(chatId, "✅ Obunani yoqildi. Botimizdan foydalanishingiz mumkin. Obunani amal qilish muddati $subscriptionDuration kunni tashkil qiladi.");

          IO.green("$chatId: ✅ Obunani yoqildi.");
        } else {
          await bot.sendMessage(
              chatId,
              "❌ Hisobingizda mablag' yetarli emas, iltimos hisobingizni to'ldiring",
              replyMarkup: topUpAccountButton
          );

          IO.yellow("$chatId: ❌ Hisobingizda mablag' yetarli emas.");
        }
      }
    } catch(e) {
      await connectionException(bot, chatId);
      IO.red("$chatId: enableSubscription => failed   ================ $e");
    }
  }

  Future<void> disableSubscription(TeleDart bot, int chatId) async {
    try {
      if(await subscribersIsActive(chatId)) {
        await bot.sendMessage(chatId, "✅ Sizda allaqachon obuna yoniq. ✅");
        IO.yellow("$chatId: ✅ Sizda allaqachon obuna yoniq. ✅");
      } else {
        await bot.sendMessage(chatId, "❌ Obuna yoqilmadi. Sizning tanlovingiz qabul qilindi.");
        IO.yellow("$chatId: ❌ Obuna yoqilmadi. Sizning tanlovingiz qabul qilindi.");
      }
    } catch(e) {
      IO.red("$chatId: $e");
    }
  }
}
