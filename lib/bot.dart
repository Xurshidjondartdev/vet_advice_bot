import 'dart:async';

import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:vet_advice_bot/core/constants.dart';
import 'package:vet_advice_bot/set_commands.dart';
import 'package:vet_advice_bot/setup.dart';
import 'package:vet_advice_bot/src/user/handlers/command_handler.dart';
import 'package:vet_advice_bot/src/user/handlers/message_handler.dart';
import 'package:vet_advice_bot/src/user/handlers/query_handler.dart';

Future<void> bot() async {
  // final String botName = (await Telegram(Constants.botToken).getMe()).username!;
  // final TeleDart bot = TeleDart(Constants.botToken, Event(botName));
  // await setup();
  // bot.start();
  // await setCommands(bot);
  // print("The bot has started");
  //
  // CommandHandler(bot).init();
  // MessageHandler(bot).init();
  // QueryHandler(bot).init();

  runZonedGuarded(
    () async {
      final String botName = (await Telegram(Constants.botToken).getMe()).username!;
      final TeleDart bot = TeleDart(Constants.botToken, Event(botName));
      await setup();
      bot.start();
      await setCommands(bot);
      print("The bot has started");

      CommandHandler(bot).init();
      MessageHandler(bot).init();
      QueryHandler(bot).init();
    },
    (error, stack) {
      print("runZonedGuarded, Xatolik yuz berdi: $error");
    },
  );
}
