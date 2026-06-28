//
//  Subscription.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 6/21/26.
//

import SwiftUI

struct Subscription: View {
    @Environment(\.dismiss) var dismiss
    @State private var subUpdater = SubscriptionUpdater()
    
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
                    
                    Spacer(minLength: 12)
                    
                    planToggle
                    
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
        .onAppear {
            subUpdater.startLoop()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showClose = true
            }
        }
        .animation(.smooth(duration: ANIM_DURATION), value: showClose)
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
                
                Text(plan.price)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? Color._white : Color.primary)
                
                Text(plan.period)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? Color._white.opacity(0.8) : Color(uiColor: .secondaryLabel))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .frame(height: 84)
            .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 20), type: isSelected ? .color(._primary) : .clear))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color(uiColor: .separator), lineWidth: 1)
            }
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
                Text("Subscribe — \(subUpdater.selectedPlan.price)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text(subUpdater.selectedPlan.period)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .opacity(0.7)
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

// MARK: - Model

struct SubscriptionBenefit: Identifiable {
    let id = UUID()
    let title: String
}

enum SubscriptionPlan {
    case weekly
    case yearly
    
    // TODO: wire these up to your real StoreKit product prices
    var title: String {
        switch self {
        case .weekly: return String(localized: "Weekly")
        case .yearly: return String(localized: "Yearly")
        }
    }

    var price: String {
        switch self {
        case .weekly: return "$4.99"
        case .yearly: return "$39.99"
        }
    }

    var period: String {
        switch self {
        case .weekly: return String(localized: "/ week")
        case .yearly: return String(localized: "/ year")
        }
    }

    var badge: String? {
        switch self {
        case .weekly: return nil
        case .yearly: return String(localized: "Best Value")
        }
    }
    
    var footnote: String {
        switch self {
        case .weekly: return String(localized: "Cancel anytime.")
        case .yearly: return String(localized: "Just $0.77/week, billed annually. Cancel anytime.")
        }
    }
}

// MARK: - Updater

@Observable class SubscriptionUpdater {
    var selectedPlan: SubscriptionPlan = .yearly
    var shimmerOffset: CGFloat = -220
    
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
        // TODO: hook up StoreKit purchase for `selectedPlan`
    }
    
    func restore() {
        // TODO: hook up StoreKit restore
    }
}

#Preview {
    Subscription()
}
