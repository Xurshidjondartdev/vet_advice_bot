import 'dart:async';

import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:vet_advice_bot/core/constants.dart';
import 'package:vet_advice_bot/src/admin/handlers_admin/command_handler_admin.dart';
import 'package:vet_advice_bot/src/services/database_service.dart';
import 'package:vet_advice_bot/src/user/handlers/common_handler.dart';

import '../../buttons/buttons.dart';
import '../../services/io_service.dart';

class CommandHandler extends DatabaseService with Buttons, CommonHandler {
  final TeleDart bot;
  CommandHandler(this.bot);

  Future<void> init() async {
    final CommandHandlerAdmin commandHandlerAdmin = CommandHandlerAdmin(bot);

    bot.onCommand().listen((event) async {
      if(event.from == null) return;

      if(event.text != "/cancel") {
        try {
          await updateState(null, event.from!.id);
        } finally {}
      }

      switch(event.text){
        case "/start":
          await start(event);
          break;
        case "/enablesubscription":
          await subscription(bot, event.from!.id);
          break;
        case "/help":
          await help(event);
          break;
        case "/appealtoadmin":
          await appealToAdmin(bot, event.from!.id);
          break;
        case "/cancel":
          await cancel(event);
          break;
        default:
          await commandHandlerAdmin.onCommand(event);
          break;
      }
    });
  }

  Future<void> start(TeleDartMessage event) async {
    try {
      if(await existsUser(event.from!.id)) {
        await event.reply(
          "Assalumu alaykum <b>${event.from!.firstName}</b>",
          parseMode: "html",
          replyMarkup: event.from?.id == Constants.adminId ? adminMainButtons : mainButtons
        );

        IO.green("/start ${event.from?.firstName}");
      } else {
        await storage("users", {
          "id": event.from!.id,
          "fullName": event.from!.firstName
        });

        await event.reply(
          "Assalumu alaykum <b>${event.from!.firstName}</b>."
          "Botimizga xush kelibsiz. Siz botimizdan muvofaqiyatli ro'yhatdan o'tdingiz.",
          parseMode: "html",
          replyMarkup: event.from?.id == Constants.adminId ? adminMainButtons : mainButtons
        );

        IO.blue("Register: ${event.from?.firstName}");
      }
    } catch(e) {
      IO.red("/start ${event.from?.firstName}");
      await connectionException(bot, event.from!.id);
    }
  }

  Future<void> help(TeleDartMessage event) async {
    final String subscriptionDuration = (Constants.subscriptionPeriod % 24 == 0)
        ? (Constants.subscriptionPeriod ~/ 24).toString()
        : (Constants.subscriptionPeriod / 24).toStringAsFixed(1);

    await event.reply(
      "🤖 <b>Bot haqida:</b>\nBu bot veterinariya xizmati uchun yaratilgan !!!\n"
      "Siz unga xar qanday veterinariyaga doir savol yo`llashingiz va maslaxat so`rashizgiz mumkin\n\n"
      "ℹ️ <b>FAQ:</b>\n1. <b>Obuna nima uchun kerak?</b> "
          "Botdan foydalanish uchun obunani yoqishingiz kerak bo'ladi.\n"
          "2. <b>Obunani yanday yoqish mumkin?</b> "
          "Obunani yoqish uchun /enablesubscription comandasini yozing yoki bosh menudan <b>\"💳 To'lov\"</b> tugmasini bosing va "
          "kelgan xabarning pastki qismidagi <b>\"✅ Obunani yoqish\"</b> tugmasini bosing.\n"
          "3. <b>Obunani yoqish narxi qancha?</b> "
          "Obunani yoqish narxi ${Constants.subscriptionPrice} UZS.\n"
          "4. <b>Obuna yoqilganidan so'ng qancha vaqtgacha amal qiladi?</b> "
          "Obuna yoqilganidan so'ng $subscriptionDuration kun amal qiladi.\n\n"
      "/start - botni qayta ishga tushurish\n"
      "/enablesubscription - obunani yoqish\n"
      "/appealToAdmin - adminga murojat\n"
      "/cancel - jarayonni to'xtatish\n"
      "/help - Ushbu yordam oynasini ko'rsatish.",
      parseMode: "html",
      replyMarkup: appealToAdminButton
    );
  }

  Future<void> cancel(TeleDartMessage event) async {
    try {
      final String? state = await getState(event.from!.id);
      IO.green("State => ${event.from?.firstName}: $state");

      if(state == null || state.isEmpty) {
        await event.reply("❗️ Sizda hech qanday jarayon mavjud emas.");
      } else {
        await updateState(null, event.from!.id);
        await event.reply("✅");
      }
    } catch(e) {
      IO.red("/cancel ${event.from?.firstName}");
      await connectionException(bot, event.from!.id);
    }
  }
}
