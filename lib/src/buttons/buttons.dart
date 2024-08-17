import 'package:teledart/model.dart';

mixin class Buttons {
  /// admin
  ReplyKeyboardMarkup get adminMainButtons => ReplyKeyboardMarkup(
      resizeKeyboard: true,
      keyboard: [
        [
          KeyboardButton(text: "📊 Obunachilar soni"),
        ],
        [
          KeyboardButton(text: "🟢 Active obunachilar soni"),
        ]
      ]
  );

  InlineKeyboardMarkup get approvalButtons => InlineKeyboardMarkup(
      inlineKeyboard: [
        [
          InlineKeyboardButton(
              text: "✅ Qabul qilish",
              callbackData: "approvePayment"
          ),
          InlineKeyboardButton(
              text: "❌ Rad etish",
              callbackData: "rejectPayment"
          )
        ]
      ]
  );

  InlineKeyboardMarkup get addPaymentButton => InlineKeyboardMarkup(
      inlineKeyboard: [
        [
          InlineKeyboardButton(
              text: "💰 Pull qo'shish 💰",
              callbackData: "addPayment"
          )
        ]
      ]
  );

  InlineKeyboardMarkup get cancellationPaymentButton => InlineKeyboardMarkup(
    inlineKeyboard: [
      [
        InlineKeyboardButton(
          text: "❌ To'lovni bekor qilish",
          callbackData: "cancellationPayment"
        )
      ]
    ]
  );




  /// users
  ReplyKeyboardMarkup get mainButtons => ReplyKeyboardMarkup(
    resizeKeyboard: true,
    keyboard: [
      [
        KeyboardButton(text: "🌽 Ratsion"),
        KeyboardButton(text: "📝 Retsept"),
      ],
      [
        KeyboardButton(text: "📋 Parvarish uchun tavsiyalar"),
      ],
      [
        KeyboardButton(text: "🔍 Diagnostika"),
        KeyboardButton(text: "📚 Qo'llanma"),
      ],
      [
        KeyboardButton(text: "💰 Balans"),
        KeyboardButton(text: "💳 To'lov"),
      ]
    ]
  );

  InlineKeyboardMarkup get topUpAccountButton => InlineKeyboardMarkup(
    inlineKeyboard: [
      [
        InlineKeyboardButton(
          text: "💳 Hisobni to'ldirish",
          callbackData: "topUpAccount"
        )
      ]
    ]
  );

  InlineKeyboardMarkup get paymentButtons => InlineKeyboardMarkup(
    inlineKeyboard: [
      [
        InlineKeyboardButton(
          text: "🧾 Chekni yuborish",
          callbackData: "sendReceipt"
        )
      ],
      [
        InlineKeyboardButton(
          text: "✅ Obunani yoqish",
          callbackData: "subscription"
        )
      ]
    ]
  );

  InlineKeyboardMarkup get enableSubscriptionButton => InlineKeyboardMarkup(
      inlineKeyboard: [
        [
          InlineKeyboardButton(
            text: "✅ Obunani yoqish",
            callbackData: "subscription"
          )
        ]
      ]
  );

  InlineKeyboardMarkup get cancelSendingReceiptButton => InlineKeyboardMarkup(
    inlineKeyboard: [
      [
        InlineKeyboardButton(
          text: "❌  Bekor qilish",
          callbackData: "cancelSendingReceipt"
        )
      ]
    ]
  );

  InlineKeyboardMarkup get appealToAdminButton => InlineKeyboardMarkup(
    inlineKeyboard: [
      [
        InlineKeyboardButton(
          text: "📨 Adminga murojat",
          callbackData: "appealToAdmin"
        )
      ]
    ]
  );

  InlineKeyboardMarkup get subscriptionButtons => InlineKeyboardMarkup(
    inlineKeyboard: [
      [
        InlineKeyboardButton(
          text: "✅ Ha",
          callbackData: "enableSubscription",
        ),
        InlineKeyboardButton(
          text: "❌ Yo'q",
          callbackData: "disableSubscription",
        ),
      ],
    ],
  );
}
