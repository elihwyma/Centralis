//
//  CentralisWidget.swift
//  CentralisWidget
//
//  Created by Andromeda on 13/03/2021.
//

import WidgetKit
import SwiftUI

struct TimetableProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimetableEntry {
        TimetableEntry(date: Date(), day: DemoDay)
    }

    func getSnapshot(in context: Context, completion: @escaping (TimetableEntry) -> ()) {
        let entry = TimetableEntry(date: Date(), day: DemoDay)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [TimetableEntry] = []
        self.getDay(completionHandler: {(success, day) -> Void in
            if success {
                entries.append(TimetableEntry(date: Date(), day: day!))
            } else {
                entries.append(TimetableEntry(date: Date(), day: nil))
            }
            let calendar = Calendar.current
            let date = calendar.date(byAdding: .hour, value: 60, to: Date())
            let timeline = Timeline(entries: entries, policy: .after(date!))
            completion(timeline)
        })
    }
    
    private func getDay(completionHandler: @escaping ((_ success: Bool, _ day: Day?) -> Void)) {
        guard let user = LoginManager.user() else { return completionHandler(false, nil) }
        LoginManager.shared.quickLogin(user, { (success, error) -> Void in
            if !success { return completionHandler(false, nil) }
            EduLink_Timetable.timetable({(success, error) -> Void in
                if !success { return completionHandler(false, nil) }
                let week = EduLinkAPI.shared.weeks.first(where: {$0.is_current}) ?? EduLinkAPI.shared.weeks.first
                guard let day = week?.days.first(where: {$0.isCurrent}) else {
                    return completionHandler(false, nil)
                }
                return completionHandler(true, day)
            })
        })
    }
}

struct TimetableEntry: TimelineEntry {
    let date: Date
    let day: Day?
}

struct LongTimetableWidgetView : View {
    var entry: TimetableProvider.Entry

    var body: some View {
        GeometryReader { reader in
            VStack(spacing: 10) {
                ForEach(entry.day?.periods ?? [Period](), id: \.self) { period in
                        HStack {
                            Text("\(period.start_time) - \(period.lesson != nil ? period.lesson.room_name : "Free") - \(period.lesson != nil ? period.lesson.subject : "Free")")
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(10)
                        .frame(width: .infinity, height: 10, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                .frame(width: reader.size.width * 0.85, height: reader.size.width / 10)
            }
            .frame(width: reader.size.width, height: reader.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct LongTimetableWidget: Widget {
    let kind: String = "Timetable Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimetableProvider()) { entry in
            LongTimetableWidgetView(entry: entry)
        }
        .configurationDisplayName("Long Timetable")
        .description("Your lessons today")
        .supportedFamilies([.systemLarge])
    }
}

struct LongTimetableWidget_Previews: PreviewProvider {
    static var previews: some View {
        LongTimetableWidgetView(entry: TimetableEntry(date: Date(), day: DemoDay))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

fileprivate let DemoDay = Day(date: "2021-03-17", isCurrent: true, name: "Monday", periods: [
    Period(empty: false, start_time: "09:00", end_time: "09:30", id: "123424", name: "MonP1", lesson: Lesson(period_id: "12314", room_name: "D35", moved: false, teacher: "", group: "Example", subject: "CS")),
    Period(empty: false, start_time: "09:35", end_time: "10:30", id: "123424", name: "MonP1", lesson: Lesson(period_id: "12314", room_name: "G12", moved: false, teacher: "", group: "Example", subject: "Maths")),
    Period(empty: false, start_time: "10:35", end_time: "11:00", id: "123424", name: "MonP1", lesson: Lesson(period_id: "12314", room_name: "G1", moved: false, teacher: "", group: "Example", subject: "English")),
    Period(empty: false, start_time: "11:15", end_time: "12:05", id: "123424", name: "MonP1", lesson: Lesson(period_id: "12314", room_name: "G1", moved: false, teacher: "", group: "Example", subject: "English")),
    Period(empty: false, start_time: "12:10", end_time: "13:00", id: "123424", name: "MonP1", lesson: Lesson(period_id: "12314", room_name: "H2", moved: false, teacher: "", group: "Example", subject: "Spanish")),
    Period(empty: false, start_time: "13:00", end_time: "13:55", id: "123424", name: "MonP1", lesson: Lesson(period_id: "12314", room_name: "Nil", moved: false, teacher: "", group: "Example", subject: "Lunch")),
    Period(empty: false, start_time: "14:00", end_time: "14:40", id: "123424", name: "MonP1", lesson: Lesson(period_id: "12314", room_name: "W31", moved: false, teacher: "", group: "Example", subject: "Chemistry")),
    Period(empty: false, start_time: "14:50", end_time: "15:30", id: "123424", name: "MonP1", lesson: Lesson(period_id: "12314", room_name: "W20", moved: false, teacher: "", group: "Example", subject: "Physics")),
])

