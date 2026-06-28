//
//  Rating.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 6/28/26.
//

import SwiftUI
import StoreKit

struct Rating: View {
    @Binding var isPresented: Bool
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        VStack(spacing: 24) {
            Text("Enjoying the app?")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                ratingOption(image: "RSad", label: "Not Good") {
                    sendFeedback()
                }

                ratingOption(image: "RNormal", label: "It's Okay") {
                    sendFeedback()
                }

                ratingOption(image: "RSmile", label: "Love It!") {
                    requestReview()
                    dismiss()
                }
            }
            
            Text("Rate us and share your feedback\nto help us improve!")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(Color._background)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: 450)
    }

    private func ratingOption(image: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)

                Text(LocalizedStringKey(label))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 20), type: .clear))
        }
        .buttonStyle(.plain)
    }

    private func sendFeedback() {
        let alert = UIAlertController(title: String(localized: "Write Your Feedback"), message: String(localized: "Help us improve by sharing your experience."), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Close"), style: .destructive))
        alert.addAction(UIAlertAction(title: String(localized: "Feedback"), style: .default, handler: { _ in
            let email = "azuby.dev@gmail.com"
            if let url = URL(string: "mailto:\(email)?subject=Photo Stitch Feedback") {
                UIApplication.shared.open(url)
            }
        }))
        
        VIEW_CONTROLLER.present(alert, animated: true)
        
        dismiss()
    }

    private func dismiss() {
        DID_RATING = true
        isPresented = false
    }
}
