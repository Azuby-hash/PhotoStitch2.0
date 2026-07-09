//
//  VideoInstruction.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 6/23/26.
//

import SwiftUI
import AVKit

struct VideoInstruction: View {
    @Environment(HomeUpdater.self) var homeUpdater

    @State private var player: AVPlayer?
    @State private var isPro = StoreKit.shared.isPro

    var body: some View {
        ZStack(alignment: .top) {
            Color._background.ignoresSafeArea()

            VStack(alignment: .center, spacing: 20) {
                // Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("Follow these steps to stitch a video shot:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .label))
                    
                    StepRow(number: "1", text: "Turn on Record and scroll your content.")
                    StepRow(number: "2", text: "Select the recorded video in the Photo Stitch app.")
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )

                if !isPro {
                    Button {
                        homeUpdater.showInstruction = false
                        homeUpdater.openSubscription(.immediate)
                    } label: {
                        HStack(spacing: 10) {
                            Image("crown.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text("Video stitching is a Pro feature. Subscribe to select and stitch videos.")
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundStyle(Color._black)
                        .frame(maxWidth: 450)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color._yellow)
                        )
                    }
                }

                VStack {
                    // Video Player
                    VideoPlayer(player: player)
                        .aspectRatio(1170 / 2532, contentMode: .fit)
                        .frame(maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .onAppear {
                            player?.play()
                        }
                        .onDisappear {
                            player?.pause()
                        }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            .padding(.top, 60)

            // Close button
            HStack {
                Text("Video Instruction")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(uiColor: .label))
                    .padding(.leading, 8)
                Spacer()
                Button {
                    homeUpdater.showInstruction = false
                } label: {
                    Image("xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(uiColor: .label))
                        .frame(width: 44, height: 44)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                }
            }
            .padding(.horizontal, 16)
            .onAppear {
                if let videoURL = Bundle.main.url(forResource: "VideoInstruction.mp4", withExtension: nil) {
                    player = AVPlayer(url: videoURL)
                }
            }
        }
    }
}

// MARK: - Step Row

private struct StepRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(uiColor: .systemBackground))
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color(uiColor: .label)))

            Text(LocalizedStringKey(text))
                .font(.system(size: 15))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
