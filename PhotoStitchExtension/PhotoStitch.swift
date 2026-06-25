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
        VStack {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image("sparkles")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Quick Stitch")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.primary)
                
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 60, height: 3)
                    .clipShape(.capsule)
            }
            
            Spacer()
            
            Button(intent: StitchPhotosIntent()) {
                VStack {
                    Image(.vertical)
                    Text("Photos")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(Color._white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color._primary.clipShape(RoundedRectangle(cornerRadius: 20)))
                .shadow(color: ._primary.opacity(0.7), radius: 10, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

fileprivate struct StitchVideosView: View {
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image("sparkles")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Quick Stitch")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.primary)
                
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 60, height: 3)
                    .clipShape(.capsule)
            }
            
            Spacer()
            
            Button(intent: StitchVideosIntent()) {
                VStack {
                    Image(.vertical)
                    Text("Video")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(Color._white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color._primary.clipShape(RoundedRectangle(cornerRadius: 20)))
                .shadow(color: ._primary.opacity(0.7), radius: 10, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

fileprivate struct StitchBothView: View {
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image("sparkles")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Quick Stitch")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.primary)
                
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 60, height: 3)
                    .clipShape(.capsule)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(intent: StitchPhotosIntent()) {
                    VStack {
                        Image(.vertical)
                        Text("Photos")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Color._white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color._primary.clipShape(RoundedRectangle(cornerRadius: 20)))
                    .shadow(color: ._primary.opacity(0.7), radius: 10, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                
                Button(intent: StitchVideosIntent()) {
                    VStack {
                        Image(.vertical)
                        Text("Video")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Color._white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color._primary.clipShape(RoundedRectangle(cornerRadius: 20)))
                    .shadow(color: ._primary.opacity(0.7), radius: 10, x: 0, y: 8)
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
                    Color._whiteVert
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
                    Color._whiteVert
                }
        }
        .configurationDisplayName("Stitch Video")
        .description("Quickly auto-stitch recent screenshot video.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
