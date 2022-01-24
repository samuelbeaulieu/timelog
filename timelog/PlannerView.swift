//
//  PlannerView.swift
//  timelog
//
//  Created by Samuel Beaulieu on 2022-01-23.
//

import SwiftUI

struct PlannerView: View {
    let today = Date()
//    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

    @State private var mondayStart = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @State private var mondayEnd = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!
    @State private var mondayBreakHour = 0
    @State private var mondayBreakMin = 30
    
    @State private var tuesdayStart = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @State private var tuesdayEnd = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!
    @State private var tuesdayBreakHour = 0
    @State private var tuesdayBreakMin = 30
    
    @State private var wednesdayStart = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @State private var wednesdayEnd = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!
    @State private var wednesdayBreakHour = 0
    @State private var wednesdayBreakMin = 30
    
    @State private var thursdayStart = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @State private var thursdayEnd = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!
    @State private var thursdayBreakHour = 0
    @State private var thursdayBreakMin = 30
    
    @State private var fridayStart = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
    @State private var fridayEnd = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
    @State private var fridayBreakHour = 0
    @State private var fridayBreakMin = 0
    
    @State private var saturdayStart = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
    @State private var saturdayEnd = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
    @State private var saturdayBreakHour = 0
    @State private var saturdayBreakMin = 0
    
    @State private var sundayStart = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
    @State private var sundayEnd = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
    @State private var sundayBreakHour = 0
    @State private var sundayBreakMin = 0
    
    func getTotalTime() -> Double {
        let mon = Int64(mondayStart.distance(to: mondayEnd)) - Int64(mondayBreakMin * 60) - Int64(mondayBreakHour * 60 * 60)
        let tue = Int64(tuesdayStart.distance(to: tuesdayEnd)) - Int64(tuesdayBreakMin * 60) - Int64(tuesdayBreakHour * 60 * 60)
        let wed = Int64(wednesdayStart.distance(to: wednesdayEnd)) - Int64(wednesdayBreakMin * 60) - Int64(wednesdayBreakHour * 60 * 60)
        let thu = Int64(thursdayStart.distance(to: thursdayEnd)) - Int64(thursdayBreakMin * 60) - Int64(thursdayBreakHour * 60 * 60)
        let fri = Int64(fridayStart.distance(to: fridayEnd)) - Int64(fridayBreakMin * 60) - Int64(fridayBreakHour * 60 * 60)
        let sat = Int64(saturdayStart.distance(to: saturdayEnd)) - Int64(saturdayBreakMin * 60) - Int64(saturdayBreakHour * 60 * 60)
        let sun = Int64(sundayStart.distance(to: sundayEnd)) - Int64(sundayBreakMin * 60) - Int64(sundayBreakHour * 60 * 60)
        
        return Double(mon + tue + wed + thu + fri + sat + sun)
    }
    
    var body: some View {
        NavigationView() {
            Form {
                HStack() {
                    VStack(alignment: .leading) {
                        Text("Planned")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(secondsToHoursMinutesSeconds(Int64(getTotalTime())))")
                    }
                    .frame(minWidth: 75, alignment: .leading)
                    Spacer()
                    VStack(alignment: .center) {
                        Text("Remaining")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(secondsToHoursMinutesSeconds(-Int64(getTotalTime() - Double(getNumberOfDaysForWeekNumber(weekNumber: Int64(Calendar.current.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))))))))")
                    }
                    .frame(minWidth: 75, alignment: .center)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("To-Do")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(secondsToHoursMinutesSeconds(getNumberOfDaysForWeekNumber(weekNumber: Int64(Calendar.current.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))))))")
                    }
                    .frame(minWidth: 75, alignment: .trailing)
                }
                .listRowSeparator(.hidden)
                ProgressView(value: getTotalTime(), total: Double(getNumberOfDaysForWeekNumber(weekNumber: Int64(Calendar.current.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))))))
                    .tint(getProgressColor(value: Int64(getTotalTime()), total: Int64(getNumberOfDaysForWeekNumber(weekNumber: Int64(Calendar.current.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0)))))))
                Section("Monday \(secondsToHoursMinutesSeconds(Int64(mondayStart.distance(to: mondayEnd)) - Int64(mondayBreakMin * 60) - Int64(mondayBreakHour * 60 * 60)))") {
                    DatePicker(selection: $mondayStart, in: ...mondayEnd, displayedComponents: [.hourAndMinute]) {
                        Text("Starts")
                    }
                    DatePicker(selection: $mondayEnd, in: mondayStart..., displayedComponents: [.hourAndMinute]) {
                        Text("Ends")
                    }
                    Section("Break Deduction") {
                        HStack() {
                            Stepper("\(mondayBreakHour)h", value: $mondayBreakHour, in: 0...23)
                            Stepper("\(mondayBreakMin)m", value: $mondayBreakMin, in: 0...55, step: 5)
                        }
                    }
                }
                Section("Tuesday \(secondsToHoursMinutesSeconds(Int64(tuesdayStart.distance(to: tuesdayEnd)) - Int64(tuesdayBreakMin * 60) - Int64(tuesdayBreakHour * 60 * 60)))") {
                    DatePicker(selection: $tuesdayStart, in: ...tuesdayEnd, displayedComponents: [.hourAndMinute]) {
                        Text("Starts")
                    }
                    DatePicker(selection: $tuesdayEnd, in: tuesdayStart..., displayedComponents: [.hourAndMinute]) {
                        Text("Ends")
                    }
                    Section("Break Deduction") {
                        HStack() {
                            Stepper("\(tuesdayBreakHour)h", value: $tuesdayBreakHour, in: 0...23)
                            Stepper("\(tuesdayBreakMin)m", value: $tuesdayBreakMin, in: 0...55, step: 5)
                        }
                    }
                }
                Section("Wednesday \(secondsToHoursMinutesSeconds(Int64(wednesdayStart.distance(to: wednesdayEnd)) - Int64(wednesdayBreakMin * 60) - Int64(wednesdayBreakHour * 60 * 60)))") {
                    DatePicker(selection: $wednesdayStart, in: ...wednesdayEnd, displayedComponents: [.hourAndMinute]) {
                        Text("Starts")
                    }
                    DatePicker(selection: $wednesdayEnd, in: wednesdayStart..., displayedComponents: [.hourAndMinute]) {
                        Text("Ends")
                    }
                    Section("Break Deduction") {
                        HStack() {
                            Stepper("\(wednesdayBreakHour)h", value: $wednesdayBreakHour, in: 0...23)
                            Stepper("\(wednesdayBreakMin)m", value: $wednesdayBreakMin, in: 0...55, step: 5)
                        }
                    }
                }
                Section("Thursday \(secondsToHoursMinutesSeconds(Int64(thursdayStart.distance(to: thursdayEnd)) - Int64(thursdayBreakMin * 60) - Int64(thursdayBreakHour * 60 * 60)))") {
                    DatePicker(selection: $thursdayStart, in: ...thursdayEnd, displayedComponents: [.hourAndMinute]) {
                        Text("Starts")
                    }
                    DatePicker(selection: $thursdayEnd, in: thursdayStart..., displayedComponents: [.hourAndMinute]) {
                        Text("Ends")
                    }
                    Section("Break Deduction") {
                        HStack() {
                            Stepper("\(thursdayBreakHour)h", value: $thursdayBreakHour, in: 0...23)
                            Stepper("\(thursdayBreakMin)m", value: $thursdayBreakMin, in: 0...55, step: 5)
                        }
                    }
                }
                Section("Friday \(secondsToHoursMinutesSeconds(Int64(fridayStart.distance(to: fridayEnd)) - Int64(fridayBreakMin * 60) - Int64(fridayBreakHour * 60 * 60)))") {
                    DatePicker(selection: $fridayStart, in: ...fridayEnd, displayedComponents: [.hourAndMinute]) {
                        Text("Starts")
                    }
                    DatePicker(selection: $fridayEnd, in: fridayStart..., displayedComponents: [.hourAndMinute]) {
                        Text("Ends")
                    }
                    Section("Break Deduction") {
                        HStack() {
                            Stepper("\(fridayBreakHour)h", value: $fridayBreakHour, in: 0...23)
                            Stepper("\(fridayBreakMin)m", value: $fridayBreakMin, in: 0...55, step: 5)
                        }
                    }
                }
                Section("Saturday \(secondsToHoursMinutesSeconds(Int64(saturdayStart.distance(to: saturdayEnd)) - Int64(saturdayBreakMin * 60) - Int64(saturdayBreakHour * 60 * 60)))") {
                    DatePicker(selection: $saturdayStart, in: ...saturdayEnd, displayedComponents: [.hourAndMinute]) {
                        Text("Starts")
                    }
                    DatePicker(selection: $saturdayEnd, in: saturdayStart..., displayedComponents: [.hourAndMinute]) {
                        Text("Ends")
                    }
                    Section("Break Deduction") {
                        HStack() {
                            Stepper("\(saturdayBreakHour)h", value: $saturdayBreakHour, in: 0...23)
                            Stepper("\(saturdayBreakMin)m", value: $saturdayBreakMin, in: 0...55, step: 5)
                        }
                    }
                }
                Section("Sunday \(secondsToHoursMinutesSeconds(Int64(sundayStart.distance(to: sundayEnd)) - Int64(sundayBreakMin * 60) - Int64(sundayBreakHour * 60 * 60)))") {
                    DatePicker(selection: $sundayStart, in: ...sundayEnd, displayedComponents: [.hourAndMinute]) {
                        Text("Starts")
                    }
                    DatePicker(selection: $sundayEnd, in: sundayStart..., displayedComponents: [.hourAndMinute]) {
                        Text("Ends")
                    }
                    Section("Break Deduction") {
                        HStack() {
                            Stepper("\(sundayBreakHour)h", value: $sundayBreakHour, in: 0...23)
                            Stepper("\(sundayBreakMin)m", value: $sundayBreakMin, in: 0...55, step: 5)
                        }
                    }
                }
            }
            .navigationTitle("\(secondsToHoursMinutesSeconds(Int64(getTotalTime()))) planned")
        }
    }
    
    func alternatingOdd(from start: Int, to end: Int, every step: Int) -> [Int] {
        guard start >= 0, step > 0  else { return [] }

        return Array(stride(from: start, through: end, by: step))
    }
}

struct PlannerView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerView()
    }
}
