import 'package:teledart/teledart.dart';
import 'package:vet_advice_bot/src/services/database_service.dart';
import 'package:vet_advice_bot/src/services/io_service.dart';

import '../../../core/constants.dart';
import '../../buttons/buttons.dart';

mixin CommonHandler on Buttons, DatabaseService {
  Future<void> payment(TeleDart bot, int chatId) async {
    try {
      final int balance = await getBalance(chatId);

      await bot.sendMessage(chatId,
        "💳 <b>Karta raqami:</b>\n<code>${Constants.cardNumber}</code>\n"
            "${Constants.cardNumberHolder}\n\n"
            "Ushbu karta raqamiga to'lov qilib chek yoki screenshotni botga yuboring. Admin to'lovni tasdiqlaganidan so'ng pul hisobingizga tushadi.\n\n"
            "🪙 <b>Joriy balans:</b> $balance UZS",
        parseMode: "html",
        replyMarkup: paymentButtons
      );
    } catch(e) {
      IO.red("$chatId: $e");
    }
  }

  Future<void> subscription(TeleDart bot, int chatId) async {
    if(chatId == Constants.adminId) {
      await bot.sendMessage(chatId, "Admin uchun obuna mavjud emas");
      return;
    }

    final String subscriptionDuration = (Constants.subscriptionPeriod % 24 == 0)
        ? (Constants.subscriptionPeriod ~/ 24).toString()
        : (Constants.subscriptionPeriod / 24).toStringAsFixed(1);

    await bot.sendMessage(
      chatId,
      "📚 <b>Obuna haqida ma'lumot:</b>\n\n"
      "1. <b>Obuna nima uchun kerak?</b>\n"
      "Botning barcha funksiyalaridan foydalanish uchun obuna bo'lishingiz kerak.\n\n"
      "2. <b>Obunani qanday yoqish mumkin?</b>\n"
      "Obunani yoqish uchun quyidagi tugmalardandan foydalaning:\n\n"
      "✅ Ha - Agar obunani yoqmoqchi bo'lsangiz.\n"
      "❌ Yo'q - Agar obunani yoqmoqchi bo'lmasangiz.\n\n"
      "Obuna narxi: ${Constants.subscriptionPrice} UZS\n"
      "Obuna amal qilish muddati: $subscriptionDuration kun.\n",
      parseMode: 'html',
      replyMarkup: subscriptionButtons
    );
  }

  Future<void> appealToAdmin(TeleDart bot, int id) async {
    if(id == Constants.adminId) {
      await bot.sendMessage(id, "❗️ Siz adminsiz. O'zingizga xabar yubora olmaysiz.");
      return;
    }

    await bot.sendMessage(id, "📑 Murojaat matnini yozib yuboring.");

    try {
      await updateState("Adminga murojat", id);
    } catch(e) {
      IO.red("$id: $e");
    }
  }

  Future<void> connectionException(TeleDart bot, int chatId) async {
    try {
      await bot.sendMessage(
        chatId,
        "❗️ Hozirgi paytda ko'plab foydalanuvchilar botdan foydalanmoqda, iltimos, birozdan keyin qayta urinib ko'ring...",
      );
    } catch(e) {
      IO.red("ChatId: $chatId, $e");
    }
  }
}
