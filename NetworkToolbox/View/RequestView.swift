//
//  RequestView.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/21.
//

import Foundation
import SwiftUI
import WebKit
import CoreData
import Combine
import Alamofire


struct RequestView: View {
    @State private var baseURL: String = ""
    @State private var method: String = "GET"
    @State private var selectedMethod = MethodType.GET
    @State private var name: String = "Untitled"
    @State private var parameters: [[String]] = []
    @State private var headers: [[String]] = []
    @State private var _body: [[String]] = []

    @StateObject var manager: RequestManager
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Request.time, ascending: true)],
        animation: .default)
    private var requests: FetchedResults<Request>
    
    // methods used to convert index into Binding<String> key value instance
    // so that input box can be update
    private func headerBindingKey(for key: Int) -> Binding<String> {
        return Binding(get: {
            guard key < headers.count else { return "" }
            return headers[key][0]
        }, set: {newValue in
            headers[key][0] = newValue
        })
    }

    private func headerBindingValue(for key: Int) -> Binding<String> {
        return Binding(get: {
            guard key < headers.count else { return "" }
            return headers[key][1]
        }, set: {newValue in
            headers[key][1] = newValue
        })
    }
    
    private func bodyBindingKey(for key: Int) -> Binding<String> {
        return Binding(get: {
            guard key < _body.count else { return "" }
            return _body[key][0]
        }, set: {newValue in
            _body[key][0] = newValue
        })
    }
    
    private func bodyBindingValue(for key: Int) -> Binding<String> {
        return Binding(get: {
            guard key < _body.count else { return "" }
            return _body[key][1]
        }, set: {newValue in
            _body[key][1] = newValue
        })
    }
    
    private func paramBindingKey(for key: Int) -> Binding<String> {
        return Binding(get: {
            guard key < parameters.count else { return "" }
            return parameters[key][0]
        }, set: {newValue in
            parameters[key][0] = newValue
        })
    }
    
    private func paramBindingValue(for key: Int) -> Binding<String> {
        return Binding(get: {
            guard key < parameters.count else { return "" }
            return parameters[key][1]
        }, set: {newValue in
            parameters[key][1] = newValue
        })
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Required Fields")) {
                    TextField(text: $name, prompt: Text("Name")) {
                        Text("Name")
                    }
                    TextField(text: $baseURL, prompt: Text("URL")) {
                        Text("URL")
                    }
                    Picker("Method", selection: $selectedMethod) {
                        ForEach(MethodType.allCases) { methodType in
                            Text(methodType.rawValue).tag(methodType)
                        }
                    }
                    
                }
                Section(header: Text("Parameters")) {
                    ForEach(parameters.indices, id:\.self) { index in
                        HStack{
                            TextField(text: paramBindingKey(for: index), prompt: Text("Key")) {
                                Text("Key")
                            }
                            TextField(text: paramBindingValue(for: index), prompt: Text("Value")) {
                                Text("Value")
                            }
                        }
                
                    }
                    .onDelete(perform: deleteParameter)
                    Button(action: addParameter) {
                        HStack{
                            Image(systemName: "plus.circle")
                            Text("Add Parameter")
                        }
                        
                    }
                    
                }
                Section(header: Text("Headers")) {
                    ForEach(headers.indices, id:\.self) { index in
                        HStack{
                            TextField(text: headerBindingKey(for: index), prompt: Text("Key")) {
                                Text("Key")
                            }
                            TextField(text: headerBindingValue(for: index), prompt: Text("Value")) {
                                Text("Value")
                            }
                        }
                
                    }
                    .onDelete(perform: deleteHeader)
                    Button(action: addHeader) {
                        HStack{
                            Image(systemName: "plus.circle")
                            Text("Add Parameter")
                        }
                        
                    }
                    
                }
                if self.selectedMethod == MethodType.POST {
                    Section(header: Text("Body")) {
                        ForEach(_body.indices, id:\.self) { index in
                            HStack{
                                TextField(text: bodyBindingKey(for: index), prompt: Text("Key")) {
                                    Text("Key")
                                }
                                TextField(text: bodyBindingValue(for: index), prompt: Text("Value")) {
                                    Text("Value")
                                }
                            }
                    
                        }
                        .onDelete(perform: deleteBody)
                        Button(action: addBody) {
                            HStack{
                                Image(systemName: "plus.circle")
                                Text("Add Parameter")
                            }
                            
                        }
                        
                    }
                }
                
            }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Request")
                            .font(.title)
                            .bold()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        VStack {
                            NavigationLink(destination: ResponseView(manager: manager), isActive: $manager.showDetail) {}
                            Button("Send") {
                                self.sendRequest()
                            }
                        }
                    }
                }
        }
        .pickerStyle(.automatic)
    }
    
    func addParameter() {
        withAnimation {
            self.parameters.append(["",""])
        }
    }
    
    func deleteParameter(offsets: IndexSet) {
        withAnimation {
            self.parameters.remove(atOffsets: offsets)
        }
    }
    
    func addHeader() {
        withAnimation {
            self.headers.append(["",""])
        }
    }
    
    func deleteHeader(offsets: IndexSet) {
        withAnimation {
            self.headers.remove(atOffsets: offsets)
        }
    }
    
    func addBody() {
        withAnimation {
            self._body.append(["",""])
        }
    }
    
    func deleteBody(offsets: IndexSet) {
        withAnimation {
            self._body.remove(atOffsets: offsets)
        }
    }
    
    func sendRequest() {
        // send HTTP request
        manager.sendRequest(name: name, url: baseURL, method: selectedMethod, parameters: parameters, headers: headers, body: _body)
        print("status", manager.isSuccess)
        
        // save request with core data
        if manager.isSuccess {
            let newRequest = Request(context: viewContext)
            newRequest.name = name
            newRequest.time = Date()
            newRequest.baseURL = baseURL
            newRequest.method = selectedMethod.rawValue
            newRequest.parameters = parameters
            newRequest.headers = headers
            newRequest.body = _body

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
