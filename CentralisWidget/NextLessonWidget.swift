//
//  NextLessonWidget.swift
//  CentralisWidgetExtension
//
//  Created by Andromeda on 14/03/2021.
//

import WidgetKit
import SwiftUI

struct NextLessonProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextLessonEntry {
        NextLessonEntry(date: Date(), lesson: DemoLesson)
    }

    func getSnapshot(in context: Context, completion: @escaping (NextLessonEntry) -> ()) {
        let entry = NextLessonEntry(date: Date(), lesson: DemoLesson)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [NextLessonEntry] = []
        self.getLesson(completionHandler: {(success, lesson) -> Void in
            if success {
                entries.append(NextLessonEntry(date: Date(), lesson: lesson!))
            } else {
                entries.append(NextLessonEntry(date: Date(), lesson: nil))
            }
            let calendar = Calendar.current
            let date = calendar.date(byAdding: .minute, value: 1, to: (lesson != nil && lesson?.endDate != nil ? lesson!.endDate! : Date()))
            let timeline = Timeline(entries: entries, policy: .after(date!))
            completion(timeline)
        })
    }
    
    private func getLesson(completionHandler: @escaping ((_ success: Bool, _ lesson: MiniLesson?) -> Void)) {
        guard let user = LoginManager.user() else { return completionHandler(false, nil) }
        LoginManager.shared.quickLogin(user, { (success, error) -> Void in
            if !success { return completionHandler(false, nil) }
            EduLink_Status.status(rootCompletion: {(success, error) -> Void in
                if !success { return completionHandler(false, nil) }
                if let upcoming = EduLinkAPI.shared.status.upcoming {
                    return completionHandler(true, upcoming)
                } else {
                    return completionHandler(false, nil)
                }
            })
        })
    }
}

struct NextLessonEntry: TimelineEntry {
    let date: Date
    let lesson: MiniLesson?
}

struct NextLessonWidgetView : View {
    var entry: NextLessonProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.lesson?.subject ?? "Free")
                .minimumScaleFactor(0.01)
                .frame(alignment: .leading)
                .padding(.leading, 5)
            Text(entry.lesson?.room ?? "Free")
                .minimumScaleFactor(0.01)
                .frame(alignment: .leading)
                .padding(.leading, 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGray5))
    }
}

struct NextLessonWidget: Widget {
    let kind: String = "Next Lesson Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextLessonProvider()) { entry in
            NextLessonWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Lesson")
        .description("Your Next Lesson")
        .supportedFamilies([.systemSmall])
    }
}

struct NextLessonWidget_Previews: PreviewProvider {
    static var previews: some View {
        NextLessonWidgetView(entry: NextLessonEntry(date: Date(), lesson: DemoLesson))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

fileprivate let DemoLesson = MiniLesson(startDate: Date(), endDate: Date(), room: "D35", subject: "Computer Studies")

