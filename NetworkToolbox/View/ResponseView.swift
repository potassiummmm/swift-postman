//
//  DetailView.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/21.
//

import Foundation
import SwiftUI
import CoreData
import Alamofire
import WebKit

enum DisplayStyle: String, CaseIterable, Identifiable {
    case pretty
    case raw
    case preview
    var id: String { self.rawValue }
}

struct ResponseView: View {
    @State private var selectedStyle = DisplayStyle.pretty
    @StateObject var manager: RequestManager
    
    var body: some View {
        VStack {
            switch selectedStyle {
            case .pretty:
                PrettyWebView(request: manager.response.request!)
            case .raw:
                WebView(request: manager.response.request!, mimeType: "text/plain")
            case .preview:
                WebView(request: manager.response.request!, mimeType: "text/html")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Picker("DisplayStyle", selection: $selectedStyle){
                    ForEach(DisplayStyle.allCases) { style in
                        Text(style.rawValue.capitalized).tag(style)
                    }
                }
            }
        }
        .pickerStyle(.segmented)
    }
}
