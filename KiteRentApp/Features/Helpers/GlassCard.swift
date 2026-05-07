//
//  GlassCard.swift
//  KiteRentApp
//

import SwiftUI
import UIKit

/// Apple-style “liquid glass” surface: material fill, subtle highlight stroke, soft shadow.
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var material: Material = .regularMaterial
    var contentPadding: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(contentPadding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(material)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.38),
                                Color.white.opacity(0.06),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.black.opacity(0.14), radius: 14, x: 0, y: 8)
    }
}

/// Soft gradient backdrop for admin screens.
struct AdminGlassBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color(red: 0.07, green: 0.08, blue: 0.12),
                    Color(red: 0.10, green: 0.11, blue: 0.16),
                    Color(red: 0.08, green: 0.09, blue: 0.13),
                ]
                : [
                    Color(red: 0.90, green: 0.93, blue: 0.98),
                    Color(red: 0.84, green: 0.88, blue: 0.96),
                    Color(red: 0.88, green: 0.91, blue: 0.97),
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

/// Section title + glass card for admin editor screens.
struct GlassEditorSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            GlassCard(cornerRadius: 18, material: .regularMaterial, contentPadding: 16, content: content)
        }
    }
}

/// Labeled field with inset glass background for editors.
struct GlassTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.tertiary)
            TextField(placeholder, text: $text)
                .autocorrectionDisabled()
                .keyboardType(keyboardType)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                }
        }
    }
}

#Preview("GlassCard") {
    ZStack {
        AdminGlassBackground()
        GlassCard {
            Text("Sample glass card")
                .font(.headline)
        }
        .padding()
    }
}
