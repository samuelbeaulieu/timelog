//
//  timelogApp.swift
//  timelog
//
//  Created by Samuel Beaulieu on 2022-01-09.
//

import SwiftUI

@main
struct timelogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
