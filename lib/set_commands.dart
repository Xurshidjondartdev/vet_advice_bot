import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';

Future<void> setCommands(TeleDart bot) async {
  await bot.setMyCommands([
    BotCommand(command: "start", description: "♻️ Botni qayta ishga tushurish"),
    BotCommand(command: "enablesubscription", description: "✅ Obunani yoqish"),
    BotCommand(command: "appealtoadmin", description: "📨 Adminga murojat"),
    BotCommand(command: "cancel", description: "❌ Jarayonni to'xtatish"),
    BotCommand(command: "help", description: "ℹ️ Yordam"),
  ]);
}
