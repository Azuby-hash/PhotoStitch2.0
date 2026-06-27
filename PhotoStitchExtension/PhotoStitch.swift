//
//  PhotoStitch.swift
//  PhotoStitch
//
//  Created by TapUniverse Dev9 on 25/6/26.
//

import WidgetKit
import SwiftUI
import AppIntents

struct StitchEntry: TimelineEntry {
    let date: Date
}

struct StitchProvider: TimelineProvider {
    func placeholder(in context: Context) -> StitchEntry {
        StitchEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (StitchEntry) -> Void) {
        completion(StitchEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StitchEntry>) -> Void) {
        completion(Timeline(entries: [StitchEntry(date: Date())], policy: .never))
    }
}

// MARK: - Atomic views

fileprivate struct StitchPhotosView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("photo.on.rectangle.angled")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color._primary)
                    .frame(width: 28, height: 28)
                    .background(Color._white, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

                Text("Photos")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color._white)
            }

            Text("Stitch screenshots into long image.")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color._white.opacity(0.9))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button(intent: StitchPhotosIntent()) {
                HStack(spacing: 6) {
                    Image("sparkles")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                    Text("Quick Stitch")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color._primary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color._white, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

fileprivate struct StitchVideosView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("play.fill")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color._primary)
                    .frame(width: 28, height: 28)
                    .background(Color._white, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

                Text("Video")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color._white)
            }

            Text("Convert recording into long image.")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color._white.opacity(0.9))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button(intent: StitchVideosIntent()) {
                HStack(spacing: 6) {
                    Image("sparkles")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                    Text("Quick Stitch")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color._primary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color._white, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

fileprivate struct StitchBothView: View {
    var body: some View {
        VStack {
            HStack {
                Image("sparkles")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color._primary)
                    .frame(width: 28, height: 28)
                    .background(Color._white, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text("Quick Stitch")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color._white)
            }

            Text("Convert recording or stitch screenshots\ninto long image.")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color._white.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(intent: StitchPhotosIntent()) {
                    VStack {
                        Image(.vertical)
                        Text("Photos")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Color._primary)
                    .frame(width: 100)
                    .padding(.vertical, 8)
                    .background(Color._white.clipShape(RoundedRectangle(cornerRadius: 20)))
                }
                .buttonStyle(.plain)
                
                Button(intent: StitchVideosIntent()) {
                    VStack {
                        Image(.vertical)
                        Text("Video")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Color._primary)
                    .frame(width: 100)
                    .padding(.vertical, 8)
                    .background(Color._white.clipShape(RoundedRectangle(cornerRadius: 20)))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Entry views

fileprivate struct StitchPhotosEntryView: View {
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            StitchBothView()
        default:
            StitchPhotosView()
        }
    }
}

fileprivate struct StitchVideosEntryView: View {
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            StitchBothView()
        default:
            StitchVideosView()
        }
    }
}

// MARK: - Widgets

struct StitchPhotosWidget: Widget {
    let kind: String = "StitchPhotos"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StitchProvider()) { _ in
            StitchPhotosEntryView()
                .containerBackground(for: .widget) {
                    Color.white
                    LinearGradient(
                        colors: [Color._primary.opacity(0.85), Color._primary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("Stitch Photos")
        .description("Quickly auto-stitch recent screenshot photos.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StitchVideosWidget: Widget {
    let kind: String = "StitchVideo"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StitchProvider()) { _ in
            StitchVideosEntryView()
                .containerBackground(for: .widget) {
                    Color.white
                    LinearGradient(
                        colors: [Color._primary.opacity(0.85), Color._primary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("Stitch Video")
        .description("Quickly auto-stitch recent screenshot video.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
