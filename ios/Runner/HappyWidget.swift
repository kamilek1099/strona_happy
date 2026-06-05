import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Be Happy Everyday", message: "✨")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), title: "Be Happy Everyday", message: "✨")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // Obieranie danych z Fluttera przez HomeWidget paczkę
        let userDefaults = UserDefaults(suiteName: "group.com.kamilmisztal.happy2")
        
        let title = userDefaults?.string(forKey: "title") ?? "Be Happy Everyday"
        let isPremium = userDefaults?.bool(forKey: "isPremium") ?? false
        let lockedMessage = userDefaults?.string(forKey: "lockedMessage") ?? "Open app to unlock ✨"
        let rawMessage = userDefaults?.string(forKey: "message") ?? lockedMessage
        
        // Logika subskrypcji
        let displayMessage = isPremium ? rawMessage : lockedMessage

        let entry = SimpleEntry(date: Date(), title: title, message: displayMessage)

        // Widget odświeża się np. co godzinę lub gdy Flutter wyśle sygnał
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let message: String
}

struct HappyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(entry.message)
                .font(.title3)
                .fontWeight(.medium)
                .minimumScaleFactor(0.5)
        }
        .padding()
    }
}

@main
struct HappyWidget: Widget {
    let kind: String = "HappyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HappyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Be Happy Everyday")
        .description("Dzisiejsza porcja szczęścia prosto na Twój pulpit.")
    }
}
