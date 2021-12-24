//
//  WebView.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let request: URLRequest
    let mimeType: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let data = try? Data(contentsOf: request.url!) {
           webView.load(data, mimeType: mimeType, characterEncodingName: "UTF-8", baseURL: request.url!)
        }
    }
}

struct PrettyWebView: UIViewRepresentable {
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let data = try? Data(contentsOf: request.url!) {
            var contentString: String
            var contentData = data
            // try to make pretty JSON
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                contentData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            } catch {}
            contentString = String(data: contentData, encoding: .utf8) ?? "Unable to decode response to UTF-8 string"
            // escape HTML characters
            contentString = contentString.replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: "&", with: "&amp;")
            // apply code highlight
            let css = "default"
            let background = "#F0F0F0"
            let htmlString = "<!DOCTYPE html>\r\n<html style='font-size:2rem; background:\(background)'>\r\n<head>\r\n<meta charset='utf-8'>\r\n<link rel='stylesheet' href='\(css).css'>\r\n<script src='highlight.pack.js'></script>\r\n<script>hljs.initHighlightingOnLoad();</script>\r\n</head>\r\n<body>\r\n<pre style='margin: 0 0 0 0'><code>\r\n\(contentString)\r\n</code></pre>\r\n</body>\r\n</html>"
            webView.loadHTMLString(htmlString, baseURL: request.url!)
        }
    }
}
