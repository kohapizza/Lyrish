//
//  CustomButton.swift.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .outline:
            return .white
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .pink
        case .secondary:
            return .gray.opacity(0.3)
        case .outline:
            return .clear
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .secondary:
            return .clear
        case .outline:
            return .gray
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary, .secondary:
            return 0
        case .outline:
            return 1
        }
    }
}
