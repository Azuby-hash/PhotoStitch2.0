//
//  Subscription.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 6/21/26.
//

import SwiftUI

struct Subscription: View {
    var config: SubscriptionConfig = .default
    
    @Environment(\.dismiss) var dismiss
    @State private var subUpdater = SubscriptionUpdater()
    
    @State private var loadToggle = !StoreKit.shared.products.isEmpty
    @State private var showClose = false
    @State private var height = CGFloat.zero
    
    var body: some View {
        ZStack {
            Color._background.ignoresSafeArea()
            
            VStack {
                imageMarketing
                
                Spacer(minLength: height + 20)
            }
            
            GeometryReader { geometry in
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask {
                        LinearGradient(stops: [
                            .init(color: .red, location: 0.8),
                            .init(color: .red.opacity(0), location: 1)
                        ], startPoint: .bottom, endPoint: .init(x: 0.5, y: (geometry.size.height - height - 80) / geometry.size.height))
                    }
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                imageMarketing.opacity(0)
                
                VStack(spacing: 0) {
                    header
                    
                    Spacer(minLength: 20)
                    
                    benefitsList
                    
                    if loadToggle {
                        Spacer(minLength: 12)
                        
                        planToggle
                    }
                    
                    Spacer(minLength: 16)
                    
                    bottomCTA
                }
                .onGeometryChange(for: CGFloat.self) { geometry in
                    return geometry.size.height
                } action: { newValue in
                    height = newValue
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .frame(maxWidth: 450)

            
            if showClose {
                close.padding(.horizontal, 20)
            }
        }
        .allowsHitTesting(!subUpdater.isPurchasing && !subUpdater.isRestoring)
        .onAppear {
            subUpdater.startLoop()
            subUpdater.syncSelectedToActive()

            if config.showCloseImmediately {
                showClose = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showClose = true
                }
            }
        }
        .animation(.smooth(duration: ANIM_DURATION), value: loadToggle)
        .animation(.smooth(duration: ANIM_DURATION), value: showClose)
        .onReceive(NotificationCenter.default.publisher(for: StoreKit.infosDidChange)) { _ in
            loadToggle = false
            loadToggle = true
            subUpdater.syncSelectedToActive()
        }
    }
    
    private var close: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image("xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .label))
                    .frame(width: 44, height: 44)
                    .modifier(MainGlass(shape: .capsule, type: .clear))
            }
        }
        .align(edge: .top, constant: 0)
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 8) {
            marketingBadge
            
            HStack(spacing: 8) {
                Text("Photo Stitch Pro")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                
                Image("sparkles")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color._primary, Color._primary.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            Text("Stitch unlimited photos, faster and cleaner.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.center)
        }
    }
    
    private var imageMarketing: some View {
        GeometryReader { geometry in
            if let image = UIImage(named: "Subscription") {
                let size = CGSize(width: image.size.width, height: image.size.height * 0.6).aspectFit(to: geometry.size)
                Image("Subscription")
                    .resizable()
                    .frame(width: size.width, height: size.height / 0.6)
                    .offset((geometry.size - size) / 2)
                    .offset(x: size.width * 0.1)
            }
        }
        .padding(.top, 44)
    }
    
    private var marketingBadge: some View {
        HStack(spacing: 6) {
            Image("heart.fill")
                .font(.system(size: 11, weight: .bold))
            Text("LOVED BY 50,000+ CREATORS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(0.4)
        }
        .foregroundStyle(Color._white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
    }
    
    // MARK: - Benefits
    
    private var benefitsList: some View {
        // TODO: replace with your real 6 benefits — title only
        let half = (subUpdater.benefits.count + 1) / 2
        let left = Array(subUpdater.benefits.prefix(half))
        let right = Array(subUpdater.benefits.suffix(from: half))
        
        return VStack(alignment: .leading, spacing: 14) {
            Text("What's included")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .textCase(.uppercase)
                .tracking(0.5)
            
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(left) { benefit in
                        BenefitRow(benefit: benefit)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(right) { benefit in
                        BenefitRow(benefit: benefit)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 24), type: .clear))
    }
    
    // MARK: - Plan toggle
    
    private var planToggle: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                planCard(.weekly)
                planCard(.yearly)
            }
            
            Text(subUpdater.selectedPlan.footnote)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                .multilineTextAlignment(.center)
        }
    }
    
    private func planCard(_ plan: SubscriptionPlan) -> some View {
        let isSelected = subUpdater.selectedPlan == plan
        let isActive = plan.isActive

        return Button {
            subUpdater.selectedPlan = plan
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(plan.title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(isSelected ? Color._white : Color.primary)

                    Spacer()

                    if let badge = plan.badge {
                        Text(badge)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(isSelected ? Color._primary : Color._white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(isSelected ? Color._white : Color._primary)
                            .clipShape(.capsule)
                    }
                }
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(plan.price)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? Color._white : Color.primary)
                    Text(plan.period)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(isSelected ? Color._white.opacity(0.8) : Color(uiColor: .secondaryLabel))
                }
                
                if !plan.introOffer.isEmpty {
                    Text(plan.introOffer)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(isSelected ? Color._white.opacity(0.85) : Color._primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .padding(.leading, 2)
            .background(isSelected ? Color._primary : Color.clear)
            .overlay {
                if isActive && !isSelected {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color._white, lineWidth: 2)
                }
            }
            .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 20), type: .clear))
            .overlay(alignment: .topLeading) {
                if isActive {
                    Image("checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color._white)
                        .background {
                            Circle()
                                .fill(Color.black)
                                .blendMode(.destinationOut)
                        }
                        .offset(x: -6, y: -6)
                }
            }
            .compositingGroup()
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: ANIM_DURATION), value: isSelected)
    }
    
    // MARK: - Bottom CTA
    
    private var bottomCTA: some View {
        VStack(spacing: 10) {
            subscribeButton
            
            HStack(spacing: 16) {
                Button {
                    subUpdater.restore()
                } label: {
                    Text("Restore")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                
                Circle()
                    .fill(Color(uiColor: .tertiaryLabel))
                    .frame(width: 3, height: 3)
                
                Button {
                    if let url = URL(string: "https://azuby-hash.github.io/AzubyTerms/") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Terms")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                
                Circle()
                    .fill(Color(uiColor: .tertiaryLabel))
                    .frame(width: 3, height: 3)
                
                Button {
                    if let url = URL(string: "https://azuby-hash.github.io/AzubyPrivacy/") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Privacy")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
            }
        }
        .padding(.bottom, 8)
    }
    
    private var subscribeButton: some View {
        Button {
            subUpdater.subscribe()
        } label: {
            HStack(spacing: 8) {
                if subUpdater.isPurchasing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color._white)
                } else if subUpdater.selectedPlan.isActive {
                    Text("You're subscribed")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                } else if loadToggle {
                    Text("Subscribe — \(subUpdater.selectedPlan.price)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text(subUpdater.selectedPlan.period)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .opacity(0.7)
                } else {
                    Text("Subscribe")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text(subUpdater.selectedPlan.period)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .opacity(0.7)
                }
            }
            .foregroundStyle(Color._white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
            .overlay {
                GeometryReader { geometry in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .blur(radius: 20)
                        .rotationEffect(.degrees(20))
                        .offset(x: subUpdater.shimmerOffset * geometry.size.width / 2)
                        .blendMode(.plusLighter)
                }
            }
            .clipShape(Capsule())
            .shadow(color: Color._primary.opacity(0.35), radius: 20, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(subUpdater.isPurchasing || subUpdater.selectedPlan.isActive)
        .opacity(subUpdater.selectedPlan.isActive ? 0.6 : 1)
        .animation(.smooth(duration: ANIM_DURATION), value: subUpdater.isPurchasing)
        .animation(.smooth(duration: ANIM_DURATION), value: subUpdater.isRestoring)
        .animation(.smooth(duration: ANIM_DURATION), value: subUpdater.selectedPlan.isActive)
    }
}

// MARK: - Benefit row

private struct BenefitRow: View {
    let benefit: SubscriptionBenefit
    
    var body: some View {
        HStack(spacing: 8) {
            Image("checkmark.circle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color._primary)
            
            Text(benefit.title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SubscriptionConfig {
    var showCloseImmediately: Bool = false

    static let `default` = SubscriptionConfig()
    static let immediate = SubscriptionConfig(showCloseImmediately: true)
}

// MARK: - Model

struct SubscriptionBenefit: Identifiable {
    let id = UUID()
    let title: String
}

enum SubscriptionPlan: String, CaseIterable {
    case weekly = "weekly"
    case yearly = "yearly"
    
    var info: StoreKit.ProductInfo? {
        if let plan = StoreKit.ProductPlan(rawValue: rawValue) {
            return try? StoreKit.shared.info(for: plan)
        }
        
        return nil
    }
    
    // TODO: wire these up to your real StoreKit product prices
    var title: String {
        info?.period.capitalized ?? "--"
    }

    var price: String {
        info?.price ?? "--"
    }

    var period: String {
        if let unit = info?.unit {
            return "/ \(unit)"
        }
        
        return ""
    }

    var badge: String? {
        switch self {
        case .weekly: return nil
        case .yearly: return String(localized: "Best Value")
        }
    }
    
    var footnote: String {
        info?.description ?? ""
    }

    var isActive: Bool {
        info?.isActive ?? false
    }
    
    var introOffer: String {
        info?.introPeriod ?? ""
    }
}

// MARK: - Updater

@Observable class SubscriptionUpdater {
    var selectedPlan: SubscriptionPlan = .yearly
    var shimmerOffset: CGFloat = -220
    var isPurchasing = false
    var isRestoring = false
    
    // TODO: replace with your real 6 benefits
    var benefits: [SubscriptionBenefit] = [
        SubscriptionBenefit(title: String(localized: "No Watermarks")),
        SubscriptionBenefit(title: String(localized: "No Ads")),
        SubscriptionBenefit(title: String(localized: "No Limits")),
        SubscriptionBenefit(title: String(localized: "High Quality Export")),
        SubscriptionBenefit(title: String(localized: "Smart Auto Stitch")),
        SubscriptionBenefit(title: String(localized: "More Features"))
    ]
    
    @ObservationIgnored private var loopTask: Task<Void, Never>?
    
    func startLoop() {
        loopTask?.cancel()
        shimmerOffset = -1
        loopTask = Task {
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: 1.6)) {
                    shimmerOffset = 1
                }
                try? await Task.sleep(for: .seconds(1.6))
                
                guard !Task.isCancelled else { break }
                
                withAnimation(.easeInOut(duration: 1.6)) {
                    shimmerOffset = -1
                }
                try? await Task.sleep(for: .seconds(1.6))
            }
        }
    }
    
    func subscribe() {
        guard !isPurchasing else { return }
        isPurchasing = true
        Task { @MainActor in
            defer { isPurchasing = false }
            do {
                try await selectedPlan.info?.purchase()
            } catch {
                print(error)
            }
        }
    }

    func restore() {
        guard !isRestoring else { return }
        isRestoring = true
        Task { @MainActor in
            defer { isRestoring = false }
            do {
                try await StoreKit.shared.restore()
            } catch {
                print(error)
            }
        }
    }

    func syncSelectedToActive() {
        if let active = SubscriptionPlan.allCases.first(where: { $0.isActive }) {
            selectedPlan = active
        }
    }
}

#Preview {
    Subscription()
}
