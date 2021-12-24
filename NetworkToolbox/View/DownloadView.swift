//
//  DownloadView.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/21.
//

import Foundation
import SwiftUI
import CoreData
import AVKit

struct DownloadButton: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let colors: Array<Color> = downloadManager.isDownloaded ? (colorScheme == .dark ? [Color(#colorLiteral(red: 0.6196078431, green: 0.6784313725, blue: 1, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.5607843137, blue: 0.9803921569, alpha: 1))] : [Color(#colorLiteral(red: 0.262745098, green: 0.0862745098, blue: 0.8588235294, alpha: 1))]) : [Color.primary]

        return HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
                    .mask(Text(downloadManager.isDownloaded ? "Downloaded" : "Download").fontWeight(.semibold).textCase(.uppercase).font(.footnote).frame(maxWidth: .infinity, alignment: .leading))
                    .frame(maxHeight: 30)

                VStack(alignment: .leading, spacing: 0) {
                    Text(downloadManager.isDownloaded ? "Delete the downloaded file" : "Watch offline")
                        .font(.caption2)
                        .foregroundColor(Color.primary)
                        .opacity(0.7)
                }
                .frame(maxWidth: 200, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            }

            Group {
                if downloadManager.isDownloading {
                    ProgressView()
                } else {
                    Image(systemName: downloadManager.isDownloaded ? "trash" : "square.and.arrow.down")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.primary)
                        .opacity(0.7)
                }
            }
            .frame(width: 32, height: 32)
            .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 1)).opacity(0.1))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(colorScheme == .dark ? Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).opacity(0.2) : Color(#colorLiteral(red: 0.9568627451, green: 0.9450980392, blue: 1, alpha: 1)))
        .cornerRadius(20)
        .onTapGesture {
            downloadManager.isDownloaded ? downloadManager.deleteFile() : downloadManager.downloadFile()
        }

    }
}

struct WatchButton: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let colors: Array<Color> = colorScheme == .dark ? [Color(#colorLiteral(red: 0.6196078431, green: 0.6784313725, blue: 1, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.5607843137, blue: 0.9803921569, alpha: 1))] : [Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))]

        return HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
                    .mask(Text("Watch video").fontWeight(.semibold).textCase(.uppercase).font(.footnote).frame(maxWidth: .infinity, alignment: .leading))
                    .frame(maxHeight: 30)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Watch the downloaded video offline")
                        .font(.caption2)
                        .foregroundColor(Color.primary)
                        .opacity(0.7)
                }
                .frame(maxWidth: 300, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            }

            Image(systemName: "tv")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color.primary)
                .opacity(0.7)
                .frame(width: 32, height: 32)
                .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 1)).opacity(0.1))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(colorScheme == .dark ? Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).opacity(0.2) : Color(#colorLiteral(red: 0.9568627451, green: 0.9450980392, blue: 1, alpha: 1)))
        .cornerRadius(20)

    }
}

struct VideoView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @State var player = AVPlayer()

    var body: some View {
        VideoPlayer(player: player)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                let playerItem = downloadManager.getVideoFileAsset()
                if let playerItem = playerItem {
                    player = AVPlayer(playerItem: playerItem)
                }
                player.play()
            }
    }
}

struct DownloadView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @State private var showVideo = false

    var body: some View {
        VStack(spacing: 40) {
            Section(header: Text("URL")) {
                TextField(text: $downloadManager.url, prompt: Text("URL")) {
                }
            }
            DownloadButton()

            if downloadManager.isDownloaded {
                WatchButton()
                    .onTapGesture {
                        showVideo = true
                    }
                    .fullScreenCover(isPresented: $showVideo, content: {
                        VideoView()
                    })
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            downloadManager.checkFileExists()
        }
    }
}
