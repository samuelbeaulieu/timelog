//
//  ContentView.swift
//  timelog
//
//  Created by Samuel Beaulieu on 2022-01-09.
//

import SwiftUI
import CoreData

enum WeekOfXDays: Int64 {
    case week3days = 94500
    case week4days = 126000
}


func getNumberOfDaysForWeekNumber(weekNumber: Int64) -> Int64 {
    if weekNumber == 2 || weekNumber == 22 || weekNumber == 37 || weekNumber == 42 {
        return WeekOfXDays.week3days.rawValue
    } else {
        return WeekOfXDays.week4days.rawValue
    }
    
}

struct SheetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentation
    @Environment(\.dismiss) var dismiss
    
    @State private var start = Date().zeroSeconds!
    @State private var end = Date().zeroSeconds!

    @State private var currentWeek = 1
    
    @State private var timeCount = "0h 0m"
    
    var body: some View {
        Form {
            Section() {
                HStack(alignment: .firstTextBaseline) {
                    Text("Time Spent")
                    Spacer()
                    Text("\(secondsToHoursMinutesSeconds(Int64(start.distance(to: end))))")
                        .foregroundColor(.secondary)
                }
            }
            DatePicker(selection: $start, in: ...end) {
                Text("Starts")
            }
            DatePicker(selection: $end, in: start...) {
                Text("Ends")
            }
            Picker("Week of Year", selection: $currentWeek) {
                ForEach(1...52, id: \.self) { week in
                    Text("Week \(week)")
                }
            }
            .pickerStyle(.wheel)
        }
        .navigationTitle("Log Time")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    addItem()
                }
            }
        }
        .onAppear {
            let calendar = Calendar.current
            let weekOfYear = calendar.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))
            currentWeek = Int(weekOfYear)
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.timeStart = start
            newItem.timeEnd = end
            newItem.duration = Int64(start.distance(to: end))
            newItem.week = Int64(currentWeek)

            do {
                try viewContext.save()
                dismiss()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentation

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timeEnd, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var showingSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let notificationManager: NotificationManager = NotificationManager.shared

    private var groupedItems: [Int64: [Item]] {
        Dictionary(grouping: items) { $0.week }
    }

    private var sections: [Int64] {
        groupedItems.keys.sorted(by: >)
    }
    
    var yearDictionary: [Int64 : [Item]] { Dictionary(grouping: items, by: { $0.week }) }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    func update(_ result : FetchedResults<Item>) -> [[Item]]{
        return  Dictionary(grouping: result){ (element : Item)  in
            element.week
        }.values.sorted() { $0[0].week > $1[0].week }
    }
    
    func getProgressColor(value: Int64, total: Int64) -> Color {
        if value == total {
            return .green
        }
        return .blue
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(update(items), id: \.self) { (section: [Item]) in
                    Section(header: (
                        HStack(alignment: .center) {
                            Text("Week \(section[0].week)")
                            Spacer()
                            VStack(alignment: .trailing) {
                                HStack() {
                                    Text("\(secondsToHoursMinutesSeconds(getLoggedTimeForWeek(weekItems: yearDictionary[section[0].week]!)))")
                                        .font(.caption2)
                                    Spacer()
                                    ProgressView(value: Double(getLoggedTimeForWeek(weekItems: yearDictionary[section[0].week]!)), total: Double(getNumberOfDaysForWeekNumber(weekNumber: section[0].week)))
                                        .tint(getProgressColor(value: getLoggedTimeForWeek(weekItems: yearDictionary[section[0].week]!), total: getNumberOfDaysForWeekNumber(weekNumber: section[0].week)))
                                    Spacer()
                                    Text("\(secondsToHoursMinutesSeconds(getNumberOfDaysForWeekNumber(weekNumber: section[0].week)))")
                                        .font(.caption2)
                                }
                            }
                            .frame(width: 170, alignment: .trailing)
                            .onTapGesture {
                                showingAlert.toggle()
                                alertMessage = showLoggedTimeWithTotalTime(weekItems: yearDictionary[section[0].week]!, weekNumber: section[0].week)
                            }
                        }
                    )) {
                        ForEach(section, id: \.self) { item in
                            HStack() {
                                Text(item.timeStart!, formatter: itemFormatter)
                                Image(systemName: "arrow.forward")
                                Text(item.timeEnd!, formatter: itemFormatter)
                            }
                            .badge(secondsToHoursMinutesSeconds(item.duration))
                        }
                        .onDelete { indexSet in
                            deleteItems(section: section, offsets: indexSet)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Time Logs")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu("Notifications") {
                        Button("Request Permission") {
                            //Call a func here don't define it
                            notificationManager.requestAuthorization()
                        }
                        Menu("Add Notifications") {
                            Menu("Monday") {
                                Button("At 12:00") {
                                    addNotification12(weekday: 2)
                                }
                                Button("At 17:00") {
                                    addNotification17(weekday: 2)
                                }
                            }
                            Menu("Tuesday") {
                                Button("At 12:00") {
                                    addNotification12(weekday: 3)
                                }
                                Button("At 17:00") {
                                    addNotification17(weekday: 3)
                                }
                            }
                            Menu("Wednesday") {
                                Button("At 12:00") {
                                    addNotification12(weekday: 4)
                                }
                                Button("At 17:00") {
                                    addNotification17(weekday: 4)
                                }
                            }
                            Menu("Thursday") {
                                Button("At 12:00") {
                                    addNotification12(weekday: 5)
                                }
                                Button("At 17:00") {
                                    addNotification17(weekday: 5)
                                }
                            }
                            Menu("Friday") {
                                Button("At 12:00") {
                                    addNotification12(weekday: 6)
                                }
                                Button("At 17:00") {
                                    addNotification17(weekday: 6)
                                }
                            }
                        }
                        Button("Delete All Notifications", action: deleteNotification)
                    }
                }
                ToolbarItem(placement: .automatic) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: showSheet) {
                        Label("Add Transaction", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSheet) {
            NavigationView {
                SheetView()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Time Remaining"), message: Text(alertMessage), dismissButton: .default(Text("Done")))
        }
    }
    
    private func showLoggedTimeWithTotalTime(weekItems: [Item], weekNumber: Int64) -> String {
        let logged = getLoggedTimeForWeek(weekItems: weekItems)
        let total = getNumberOfDaysForWeekNumber(weekNumber: weekNumber)
        
        let remaining = total - logged
        
        let remainingInDays = (Double(total) - Double(logged)) / Double(31500)
        
        if remaining == 0 {
            return "You're done! ⌛️\nGo enjoy your free time!! 🥳"
        }

        return "\(secondsToHoursMinutesSeconds(remaining)) or \(String(format:"%.3f", remainingInDays)) days (of 8h 45m)"
    }

    private func getLoggedTimeForWeek(weekItems: [Item]) -> Int64 {
        var total: Int64 = 0
        
        for day in weekItems {
            total += day.duration
        }
        
        return total
    }
    
    private func addNotification12(weekday: Int) {
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = 12
        dateComponents.minute = 00
        //Reusable method
        self.notificationManager.scheduleTriggerNotification(title: "Timelog", body: "Don't forget to enter your time for this morning!", categoryIdentifier: "reminder", dateComponents: dateComponents, repeats: true)
    }
    
    private func addNotification17(weekday: Int) {
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = 17
        dateComponents.minute = 00
        dateComponents.timeZone = .current
        //Reusable method
        self.notificationManager.scheduleTriggerNotification(title: "Timelog", body: "Don't forget to enter your time for this afternoon!", categoryIdentifier: "reminder", dateComponents: dateComponents, repeats: true)
    }
    
    private func deleteNotification() {
        self.notificationManager.deleteNotifications()
    }
    
    private func showSheet() {
        showingSheet.toggle()
    }

    private func deleteItems(section: [Item], offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let todo = section[index]
                viewContext.delete(todo)
            }

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    formatter.dateFormat = "MMM d, HH:mm"
    return formatter
}()

private let itemDateFormatter: DateFormatter = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.firstWeekday = 2
    let formatter = DateFormatter()
    formatter.calendar = calendar
    formatter.dateFormat = "W"
    return formatter
}()

func secondsToHoursMinutesSeconds(_ seconds: Int64) -> String {
    if seconds / 3600 == 0 {
        return "\((seconds % 3600) / 60)m"
    }
    if (seconds % 3600) / 60 == 0 {
        return "\(seconds / 3600)h"
    }
    if seconds < 0 {
        return "0h 0m"
    }
    return "\(seconds / 3600)h \((seconds % 3600) / 60)m"
}

extension Date {
    
    var year: Int { Calendar.current.dateComponents([.weekOfYear], from: self).weekOfYear ?? 0 }
    
    var zeroSeconds: Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: dateComponents)
    }
    
    var weekOfYear: Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "W"
        return Int(formatter.string(from: self))!
    }

}

extension Sequence {
    func group<Key>(by keyPath: KeyPath<Element, Key>) -> [Key: [Element]] where Key: Hashable {
        return Dictionary(grouping: self, by: {
            $0[keyPath: keyPath]
        })
    }
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate{
    static let shared: NotificationManager = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    
    private override init(){
        super.init()
        notificationCenter.delegate = self
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Access Granted!")
            } else {
                print("Access Not Granted")
            }
        }
    }
    
    func deleteNotifications(){
        notificationCenter.removeAllPendingNotificationRequests()
    }

    func scheduleTriggerNotification(title: String, body: String, categoryIdentifier: String, dateComponents : DateComponents, repeats: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = categoryIdentifier
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
    }

    func printNotifications(){
        notificationCenter.getPendingNotificationRequests { request in
            for req in request{
                if req.trigger is UNCalendarNotificationTrigger{
                    print((req.trigger as! UNCalendarNotificationTrigger).nextTriggerDate()?.description ?? "invalid next trigger date")
                }
            }
        }
    }

    //MARK: UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.banner)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
