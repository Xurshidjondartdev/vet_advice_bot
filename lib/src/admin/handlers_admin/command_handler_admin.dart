import 'dart:async';

import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:vet_advice_bot/core/constants.dart';
import 'package:vet_advice_bot/src/services/database_service.dart';
import 'package:vet_advice_bot/src/services/io_service.dart';

import '../../buttons/buttons.dart';

class CommandHandlerAdmin extends DatabaseService with Buttons {
  final TeleDart bot;
  CommandHandlerAdmin(this.bot);

  Future<void> onCommand(TeleDartMessage event) async {
    if(event.text == "/admin" && event.from?.id == Constants.adminId) {
      await event.reply(
        "Tasdiqlandi. Siz adminsiz",
        replyMarkup: adminMainButtons
      );

      IO.green("/admin");
    } else {
      IO.red("${event.from?.firstName}: /admin");
    }
  }
}
