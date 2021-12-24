//
//  ContentView.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var manager = RequestManager()
    @StateObject var downloadManager = DownloadManager()

    var body: some View {
        TabView{
            DownloadView()
                .environmentObject(downloadManager)
                .tabItem{
                    Image(systemName: "arrow.down.circle")
                    Text("Download")
                }
            RequestView(manager: manager)
                .tabItem{
                    Image(systemName: "plus.app")
                    Text("New Request")
                }
            HistoryView()
                .tabItem{
                    Image(systemName: "clock")
                    Text("History")
                }
        }
    }
}
