//
//  Onboarding.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/6/26.
//

import SwiftUI

struct Onboarding: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "rectangle.grid.1x2.fill.2.line",
            title: String(localized: "Welcome to\nPhoto Stitch"),
            subtitle: String(localized: "Combine multiple screenshots into one clean, seamless image in seconds.")
        ),
        OnboardingPage(
            icon: "play.rectangle.fill",
            title: String(localized: "Video to Long Image"),
            subtitle: String(localized: "Record a slow scroll on your screen and import the video — Photo Stitch converts it into one seamless long screenshot.")
        ),
        OnboardingPage(
            icon: "sparkles",
            title: String(localized: "Smart Auto Stitch"),
            subtitle: String(localized: "Just select your photos and the app automatically detect and stitch them together.")
        ),
    ]

    var body: some View {
        ZStack {
            Color._background.ignoresSafeArea()

            VStack(spacing: 0) {
                pageContent

                Spacer(minLength: 32)

                bottomControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .frame(maxWidth: 450)
            }

            closeButton
                .padding(.horizontal, 16)
        }
        .animation(.smooth(duration: ANIM_DURATION), value: currentPage)
    }

    // MARK: - Pages

    private var pageContent: some View {
        TabView(selection: $currentPage) {
            ForEach(pages.indices, id: \.self) { index in
                pageView(pages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color._primary.opacity(0.12))
                    .frame(width: 140, height: 140)

                Image(page.icon)
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color._primary, Color._primary.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: 450)
            }

            Spacer()
        }
    }

    // MARK: - Bottom

    private var bottomControls: some View {
        VStack(spacing: 20) {
            pageDots

            actionButton
        }
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color._primary : Color(uiColor: .separator))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
            }
        }
    }

    private var actionButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                currentPage += 1
            } else {
                dismiss()
            }
        } label: {
            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color._white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
                .shadow(color: Color._primary.opacity(0.35), radius: 20, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Skip

    private var closeButton: some View {
        HStack {
            Spacer()
            if currentPage >= 1 {
                Button {
                    dismiss()
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                }
                .transition(.blurReplace.combined(with: .opacity))
            }
        }
        .align(edge: .top, constant: 0)
    }
}

// MARK: - Model

private struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
}

#Preview {
    Onboarding()
}
