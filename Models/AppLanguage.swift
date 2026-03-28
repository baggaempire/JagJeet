import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case english = "english"
    case hindi = "hindi"
    case punjabi = "punjabi"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .hindi:
            return "Hindi"
        case .punjabi:
            return "Punjabi"
        }
    }

    var reflectionsFileName: String {
        switch self {
        case .english:
            return "reflections"
        case .hindi:
            return "reflections_hi"
        case .punjabi:
            return "reflections_pa"
        }
    }

    func text(_ key: AppTextKey) -> String {
        switch self {
        case .english:
            return englishText(key)
        case .hindi:
            return hindiText(key)
        case .punjabi:
            return punjabiText(key)
        }
    }

    private func englishText(_ key: AppTextKey) -> String {
        switch key {
        case .homeTab: return "Home"
        case .learnTab: return "Learn"
        case .savedTab: return "Saved"
        case .settingsTab: return "Settings"
        case .todaysWisdom: return "Today's Wisdom"
        case .takeAMoment: return "Take a moment."
        case .featuredVerse: return "Featured verse"
        case .openTodaysReflection: return "Open Today's Reflection"
        case .noReflectionAvailable: return "No reflection available."
        case .onboardingTitle: return "Sikhi Sikho"
        case .onboardingMessage: return "Discover the wisdom of Gurbani\nin just a few minutes each day"
        case .chooseYourLanguage: return "Choose your language"
        case .howOftenNotified: return "How often would you like to get notified?"
        case .canChangeInSettings: return "You can change this anytime in Settings"
        case .getStarted: return "Get Started"
        case .settingUp: return "Setting Up..."
        case .languageSection: return "Language"
        case .chooseAppLanguage: return "Choose app language"
        case .notificationsSection: return "Notifications"
        case .enableReminders: return "Enable reminders"
        case .timesPerDay: return "Times per day"
        case .reminder: return "Reminder"
        case .useRandomTimes: return "Use random times each day"
        case .saveSettings: return "Save Settings"
        case .saved: return "Saved"
        case .settingsSaved: return "Settings saved"
        case .supportSection: return "Support"
        case .supportDescription: return "Found an issue or have an idea? Send feedback anytime."
        case .feedbackRequest: return "Share feedback\n(less than a minute)"
        case .showWelcomeAgain: return "Show Welcome Screen Again"
        case .openingFeedbackForm: return "Opening feedback form"
        case .settingsTitle: return "Settings"
        case .progress: return "Progress"
        case .startChaupaiPath: return "Start Chaupai Sahib Path"
        case .resumeChaupaiPath: return "Resume Chaupai Sahib Path"
        case .beginChaupaiAgain: return "Begin Chaupai Path Again"
        case .startJapjiPath: return "Start Japji Sahib Path"
        case .resumeJapjiPath: return "Resume Japji Sahib Path"
        case .beginJapjiAgain: return "Begin Japji Path Again"
        case .chaupaiPathSubtitle: return "Study all Chaupai Sahib verses in a swipe-right flashcard flow."
        case .japjiPathSubtitle: return "Learn Japji Sahib verses with saved progress and continue any time."
        case .noSavedVerses: return "No saved verses yet."
        case .tapBookmarkToSave: return "Tap the bookmark icon to save wisdom."
        case .pathLabel: return "Path"
        case .next: return "Next"
        case .previous: return "Previous"
        case .save: return "Save"
        case .share: return "Share"
        case .gurmukhiVerse: return "Gurmukhi Verse"
        case .simpleExplanation: return "Simple Explanation"
        case .reflectionForToday: return "Reflection For Today"
        case .gurbaniVerse: return "Gurbani Verse"
        case .swipeRightToNext: return "Swipe right to mark complete and move to the next card"
        case .completed: return "Completed"
        case .completeNext: return "Complete + Next"
        case .pathComplete: return "Path complete"
        case .startAgain: return "Start Again"
        case .notNow: return "Not Now"
        case .noChaupaiAvailable: return "No Chaupai Sahib verses available yet."
        case .noJapjiAvailable: return "No Japji Sahib verses available yet."
        case .chaupaiRestartMessage: return "You've completed every Chaupai verse in this path. If you'd like, you can begin again gently from the start."
        case .japjiRestartMessage: return "You've completed every Japji verse in this path. If you'd like, you can begin again gently from the start."
        case .ofCompleted: return "completed"
        case .verse: return "Verse"
        case .noReflectionYet: return "No reflection available yet."
        case .shareFooter: return "Shared from \"JagJeet\" app - Your daily spiritual learning!\nDownload today"
        }
    }

    private func hindiText(_ key: AppTextKey) -> String {
        switch key {
        case .homeTab: return "होम"
        case .learnTab: return "सीखें"
        case .savedTab: return "सहेजे गए"
        case .settingsTab: return "सेटिंग्स"
        case .todaysWisdom: return "आज का ज्ञान"
        case .takeAMoment: return "एक पल रुकिए."
        case .featuredVerse: return "आज का पद"
        case .openTodaysReflection: return "आज का चिंतन खोलें"
        case .noReflectionAvailable: return "अभी कोई चिंतन उपलब्ध नहीं है."
        case .onboardingTitle: return "सिखी सिखो"
        case .onboardingMessage: return "हर दिन कुछ ही मिनटों में\nगुरबाणी की बुद्धि से जुड़ें"
        case .chooseYourLanguage: return "अपनी भाषा चुनें"
        case .howOftenNotified: return "आप कितनी बार सूचना पाना चाहेंगे?"
        case .canChangeInSettings: return "आप इसे बाद में सेटिंग्स में बदल सकते हैं"
        case .getStarted: return "शुरू करें"
        case .settingUp: return "सेट किया जा रहा है..."
        case .languageSection: return "भाषा"
        case .chooseAppLanguage: return "ऐप की भाषा चुनें"
        case .notificationsSection: return "सूचनाएं"
        case .enableReminders: return "रिमाइंडर चालू करें"
        case .timesPerDay: return "दिन में बार"
        case .reminder: return "रिमाइंडर"
        case .useRandomTimes: return "हर दिन अलग समय उपयोग करें"
        case .saveSettings: return "सेटिंग्स सहेजें"
        case .saved: return "सहेजा गया"
        case .settingsSaved: return "सेटिंग्स सहेजी गईं"
        case .supportSection: return "सहायता"
        case .supportDescription: return "कोई समस्या मिली या कोई सुझाव है? कभी भी प्रतिक्रिया भेजें."
        case .feedbackRequest: return "फीडबैक साझा करें\n(एक मिनट से कम)"
        case .showWelcomeAgain: return "स्वागत स्क्रीन फिर दिखाएं"
        case .openingFeedbackForm: return "फीडबैक फॉर्म खोला जा रहा है"
        case .settingsTitle: return "सेटिंग्स"
        case .progress: return "प्रगति"
        case .startChaupaiPath: return "चौपई साहिब पथ शुरू करें"
        case .resumeChaupaiPath: return "चौपई साहिब पथ जारी रखें"
        case .beginChaupaiAgain: return "चौपई पथ फिर शुरू करें"
        case .startJapjiPath: return "जपजी साहिब पथ शुरू करें"
        case .resumeJapjiPath: return "जपजी साहिब पथ जारी रखें"
        case .beginJapjiAgain: return "जपजी पथ फिर शुरू करें"
        case .chaupaiPathSubtitle: return "चौपई साहिब के सभी पद स्वाइप-राइट फ्लैशकार्ड रूप में पढ़ें."
        case .japjiPathSubtitle: return "जपजी साहिब के पद प्रगति के साथ सीखें और कभी भी जारी रखें."
        case .noSavedVerses: return "अभी तक कोई पद सहेजा नहीं गया."
        case .tapBookmarkToSave: return "ज्ञान सहेजने के लिए बुकमार्क पर टैप करें."
        case .pathLabel: return "पथ"
        case .next: return "अगला"
        case .previous: return "पिछला"
        case .save: return "सहेजें"
        case .share: return "साझा करें"
        case .gurmukhiVerse: return "गुरमुखी पद"
        case .simpleExplanation: return "सरल व्याख्या"
        case .reflectionForToday: return "आज का चिंतन"
        case .gurbaniVerse: return "गुरबाणी पद"
        case .swipeRightToNext: return "पूर्ण करने और अगले कार्ड पर जाने के लिए दाईं ओर स्वाइप करें"
        case .completed: return "पूर्ण"
        case .completeNext: return "पूर्ण + अगला"
        case .pathComplete: return "पथ पूरा हुआ"
        case .startAgain: return "फिर शुरू करें"
        case .notNow: return "अभी नहीं"
        case .noChaupaiAvailable: return "अभी कोई चौपई साहिब पद उपलब्ध नहीं है."
        case .noJapjiAvailable: return "अभी कोई जपजी साहिब पद उपलब्ध नहीं है."
        case .chaupaiRestartMessage: return "आपने इस पथ के सभी चौपई पद पूरे कर लिए हैं. यदि चाहें, तो आप इसे फिर से शांति से शुरू कर सकते हैं."
        case .japjiRestartMessage: return "आपने इस पथ के सभी जपजी पद पूरे कर लिए हैं. यदि चाहें, तो आप इसे फिर से शांति से शुरू कर सकते हैं."
        case .ofCompleted: return "पूर्ण"
        case .verse: return "पद"
        case .noReflectionYet: return "अभी कोई चिंतन उपलब्ध नहीं है."
        case .shareFooter: return "\"JagJeet\" ऐप से साझा किया गया - आपका दैनिक आध्यात्मिक अध्ययन!\nआज ही डाउनलोड करें"
        }
    }

    private func punjabiText(_ key: AppTextKey) -> String {
        switch key {
        case .homeTab: return "ਘਰ"
        case .learnTab: return "ਸਿੱਖੋ"
        case .savedTab: return "ਸੰਭਾਲੇ"
        case .settingsTab: return "ਸੈਟਿੰਗਜ਼"
        case .todaysWisdom: return "ਅੱਜ ਦਾ ਗਿਆਨ"
        case .takeAMoment: return "ਇੱਕ ਪਲ ਰੁਕੋ."
        case .featuredVerse: return "ਅੱਜ ਦੀ ਬਾਣੀ"
        case .openTodaysReflection: return "ਅੱਜ ਦਾ ਚਿੰਤਨ ਖੋਲ੍ਹੋ"
        case .noReflectionAvailable: return "ਹਾਲੇ ਕੋਈ ਚਿੰਤਨ ਉਪਲਬਧ ਨਹੀਂ ਹੈ."
        case .onboardingTitle: return "ਸਿਖੀ ਸਿੱਖੋ"
        case .onboardingMessage: return "ਹਰ ਰੋਜ਼ ਕੁਝ ਮਿੰਟਾਂ ਵਿੱਚ\nਗੁਰਬਾਣੀ ਦੀ ਸਿਆਣਪ ਨਾਲ ਜੁੜੋ"
        case .chooseYourLanguage: return "ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ"
        case .howOftenNotified: return "ਤੁਸੀਂ ਕਿੰਨੀ ਵਾਰ ਸੂਚਨਾ ਲੈਣਾ ਚਾਹੋਗੇ?"
        case .canChangeInSettings: return "ਤੁਸੀਂ ਇਸਨੂੰ ਬਾਅਦ ਵਿੱਚ ਸੈਟਿੰਗਜ਼ ਵਿੱਚ ਬਦਲ ਸਕਦੇ ਹੋ"
        case .getStarted: return "ਸ਼ੁਰੂ ਕਰੋ"
        case .settingUp: return "ਸੈਟ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ..."
        case .languageSection: return "ਭਾਸ਼ਾ"
        case .chooseAppLanguage: return "ਐਪ ਦੀ ਭਾਸ਼ਾ ਚੁਣੋ"
        case .notificationsSection: return "ਸੂਚਨਾਵਾਂ"
        case .enableReminders: return "ਰਿਮਾਇੰਡਰ ਚਾਲੂ ਕਰੋ"
        case .timesPerDay: return "ਦਿਨ ਵਿੱਚ ਵਾਰ"
        case .reminder: return "ਰਿਮਾਇੰਡਰ"
        case .useRandomTimes: return "ਹਰ ਦਿਨ ਵੱਖਰੇ ਸਮੇਂ ਵਰਤੋ"
        case .saveSettings: return "ਸੈਟਿੰਗਜ਼ ਸੰਭਾਲੋ"
        case .saved: return "ਸੰਭਾਲਿਆ ਗਿਆ"
        case .settingsSaved: return "ਸੈਟਿੰਗਜ਼ ਸੰਭਾਲੀਆਂ ਗਈਆਂ"
        case .supportSection: return "ਸਹਾਇਤਾ"
        case .supportDescription: return "ਕੋਈ ਗਲਤੀ ਮਿਲੀ ਜਾਂ ਕੋਈ ਨਵਾਂ ਵਿਚਾਰ ਹੈ? ਕਿਸੇ ਵੀ ਵੇਲੇ ਫੀਡਬੈਕ ਭੇਜੋ."
        case .feedbackRequest: return "ਫੀਡਬੈਕ ਸਾਂਝੀ ਕਰੋ\n(ਇੱਕ ਮਿੰਟ ਤੋਂ ਘੱਟ)"
        case .showWelcomeAgain: return "ਵੈਲਕਮ ਸਕ੍ਰੀਨ ਮੁੜ ਵੇਖਾਓ"
        case .openingFeedbackForm: return "ਫੀਡਬੈਕ ਫਾਰਮ ਖੁੱਲ ਰਿਹਾ ਹੈ"
        case .settingsTitle: return "ਸੈਟਿੰਗਜ਼"
        case .progress: return "ਪ੍ਰਗਤੀ"
        case .startChaupaiPath: return "ਚੌਪਈ ਸਾਹਿਬ ਪਥ ਸ਼ੁਰੂ ਕਰੋ"
        case .resumeChaupaiPath: return "ਚੌਪਈ ਸਾਹਿਬ ਪਥ ਜਾਰੀ ਰੱਖੋ"
        case .beginChaupaiAgain: return "ਚੌਪਈ ਪਥ ਮੁੜ ਸ਼ੁਰੂ ਕਰੋ"
        case .startJapjiPath: return "ਜਪਜੀ ਸਾਹਿਬ ਪਥ ਸ਼ੁਰੂ ਕਰੋ"
        case .resumeJapjiPath: return "ਜਪਜੀ ਸਾਹਿਬ ਪਥ ਜਾਰੀ ਰੱਖੋ"
        case .beginJapjiAgain: return "ਜਪਜੀ ਪਥ ਮੁੜ ਸ਼ੁਰੂ ਕਰੋ"
        case .chaupaiPathSubtitle: return "ਚੌਪਈ ਸਾਹਿਬ ਦੇ ਸਾਰੇ ਪਦ ਸਵਾਈਪ-ਰਾਈਟ ਫਲੈਸ਼ਕਾਰਡ ਰੂਪ ਵਿੱਚ ਪੜ੍ਹੋ."
        case .japjiPathSubtitle: return "ਜਪਜੀ ਸਾਹਿਬ ਦੇ ਪਦ ਪ੍ਰਗਤੀ ਨਾਲ ਸਿੱਖੋ ਅਤੇ ਕਿਸੇ ਵੀ ਵੇਲੇ ਜਾਰੀ ਰੱਖੋ."
        case .noSavedVerses: return "ਹਾਲੇ ਕੋਈ ਪਦ ਸੰਭਾਲਿਆ ਨਹੀਂ ਗਿਆ."
        case .tapBookmarkToSave: return "ਗਿਆਨ ਸੰਭਾਲਣ ਲਈ ਬੁੱਕਮਾਰਕ ਆਈਕਨ ਦਬਾਓ."
        case .pathLabel: return "ਪਥ"
        case .next: return "ਅਗਲਾ"
        case .previous: return "ਪਿਛਲਾ"
        case .save: return "ਸੰਭਾਲੋ"
        case .share: return "ਸਾਂਝਾ ਕਰੋ"
        case .gurmukhiVerse: return "ਗੁਰਮੁਖੀ ਪਦ"
        case .simpleExplanation: return "ਸੌਖੀ ਵਿਆਖਿਆ"
        case .reflectionForToday: return "ਅੱਜ ਲਈ ਚਿੰਤਨ"
        case .gurbaniVerse: return "ਗੁਰਬਾਣੀ ਪਦ"
        case .swipeRightToNext: return "ਪੂਰਾ ਕਰਕੇ ਅਗਲੇ ਕਾਰਡ ਲਈ ਸੱਜੇ ਵੱਲ ਸਵਾਈਪ ਕਰੋ"
        case .completed: return "ਪੂਰਾ"
        case .completeNext: return "ਪੂਰਾ + ਅਗਲਾ"
        case .pathComplete: return "ਪਥ ਪੂਰਾ ਹੋ ਗਿਆ"
        case .startAgain: return "ਮੁੜ ਸ਼ੁਰੂ ਕਰੋ"
        case .notNow: return "ਹੁਣ ਨਹੀਂ"
        case .noChaupaiAvailable: return "ਹਾਲੇ ਕੋਈ ਚੌਪਈ ਸਾਹਿਬ ਪਦ ਉਪਲਬਧ ਨਹੀਂ ਹੈ."
        case .noJapjiAvailable: return "ਹਾਲੇ ਕੋਈ ਜਪਜੀ ਸਾਹਿਬ ਪਦ ਉਪਲਬਧ ਨਹੀਂ ਹੈ."
        case .chaupaiRestartMessage: return "ਤੁਸੀਂ ਇਸ ਪਥ ਦੇ ਸਾਰੇ ਚੌਪਈ ਪਦ ਪੂਰੇ ਕਰ ਲਏ ਹਨ. ਜੇ ਚਾਹੋ, ਤਾਂ ਇਸਨੂੰ ਮੁੜ ਸ਼ਾਂਤੀ ਨਾਲ ਸ਼ੁਰੂ ਕਰ ਸਕਦੇ ਹੋ."
        case .japjiRestartMessage: return "ਤੁਸੀਂ ਇਸ ਪਥ ਦੇ ਸਾਰੇ ਜਪਜੀ ਪਦ ਪੂਰੇ ਕਰ ਲਏ ਹਨ. ਜੇ ਚਾਹੋ, ਤਾਂ ਇਸਨੂੰ ਮੁੜ ਸ਼ਾਂਤੀ ਨਾਲ ਸ਼ੁਰੂ ਕਰ ਸਕਦੇ ਹੋ."
        case .ofCompleted: return "ਪੂਰੇ"
        case .verse: return "ਪਦ"
        case .noReflectionYet: return "ਹਾਲੇ ਕੋਈ ਚਿੰਤਨ ਉਪਲਬਧ ਨਹੀਂ ਹੈ."
        case .shareFooter: return "\"JagJeet\" ਐਪ ਤੋਂ ਸਾਂਝਾ ਕੀਤਾ ਗਿਆ - ਤੁਹਾਡੀ ਰੋਜ਼ਾਨਾ ਆਤਮਿਕ ਸਿੱਖਿਆ!\nਅੱਜ ਹੀ ਡਾਊਨਲੋਡ ਕਰੋ"
        }
    }
}

enum AppTextKey {
    case homeTab
    case learnTab
    case savedTab
    case settingsTab
    case todaysWisdom
    case takeAMoment
    case featuredVerse
    case openTodaysReflection
    case noReflectionAvailable
    case onboardingTitle
    case onboardingMessage
    case chooseYourLanguage
    case howOftenNotified
    case canChangeInSettings
    case getStarted
    case settingUp
    case languageSection
    case chooseAppLanguage
    case notificationsSection
    case enableReminders
    case timesPerDay
    case reminder
    case useRandomTimes
    case saveSettings
    case saved
    case settingsSaved
    case supportSection
    case supportDescription
    case feedbackRequest
    case showWelcomeAgain
    case openingFeedbackForm
    case settingsTitle
    case progress
    case startChaupaiPath
    case resumeChaupaiPath
    case beginChaupaiAgain
    case startJapjiPath
    case resumeJapjiPath
    case beginJapjiAgain
    case chaupaiPathSubtitle
    case japjiPathSubtitle
    case noSavedVerses
    case tapBookmarkToSave
    case pathLabel
    case next
    case previous
    case save
    case share
    case gurmukhiVerse
    case simpleExplanation
    case reflectionForToday
    case gurbaniVerse
    case swipeRightToNext
    case completed
    case completeNext
    case pathComplete
    case startAgain
    case notNow
    case noChaupaiAvailable
    case noJapjiAvailable
    case chaupaiRestartMessage
    case japjiRestartMessage
    case ofCompleted
    case verse
    case noReflectionYet
    case shareFooter
}
