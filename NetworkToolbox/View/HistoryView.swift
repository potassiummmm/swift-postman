//
//  HistoryView.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/21.
//

import Foundation
import SwiftUI
import CoreData


struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Request.time, ascending: true)],
        animation: .default)
    private var requests: FetchedResults<Request>

    var body: some View {
        NavigationView {
            List {
                ForEach(requests) { request in
                    NavigationLink {
                        RequestDetailView(request: request)
                    } label: {
                        VStack (alignment: .leading) {
                            Text(request.name!)
                                .font(.title)
                                .bold()
                                .fixedSize()
                            Text(request.baseURL!)
                        }
                        
                    }
                }
                .onDelete(perform: deleteRequest)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addRequest) {
                        Label("Add Request", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addRequest() {
        withAnimation {
            let newRequest = Request(context: viewContext)
            newRequest.name = "Untitled"
            newRequest.time = Date()
            newRequest.baseURL = "http://test"
            newRequest.method = "GET"
            newRequest.parameters = []
            newRequest.headers = []
            newRequest.body = []

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

    private func deleteRequest(offsets: IndexSet) {
        withAnimation {
            offsets.map { requests[$0] }.forEach(viewContext.delete)

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
    return formatter
}()


struct RequestDetailView: View {
    var request: FetchedResults<Request>.Element
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                Text(request.name!)
            }
            Section(header: Text("URL")) {
                Text(request.baseURL!)
            }
            Section(header: Text("Method")) {
                Text(request.baseURL!)
            }
            Section(header: Text("Parameters")) {
                ForEach(request.parameters!.indices, id:\.self) { index in
                    HStack{
                        Text(request.parameters![index][0])
                        Text(request.parameters![index][1])
                    }
                }
            }
            Section(header: Text("Headers")) {
                ForEach(request.headers!.indices, id:\.self) { index in
                    HStack{
                        Text(request.headers![index][0])
                        Text(request.headers![index][1])
                    }
                }
            }
            Section(header: Text("Body")) {
                ForEach(request.body!.indices, id:\.self) { index in
                    HStack{
                        Text(request.body![index][0])
                        Text(request.body![index][1])
                    }
                }
            }
        }
    }
}
