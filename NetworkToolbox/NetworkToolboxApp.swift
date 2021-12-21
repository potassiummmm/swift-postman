//
//  NetworkToolboxApp.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/21.
//

import SwiftUI

@main
struct NetworkToolboxApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
