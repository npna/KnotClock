//
//  FormButton.swift
//  KnotClock
//
//  Created by NA on 2/22/23.
//

import SwiftUI

struct FormButton: ButtonStyle {
    var backgroundColor = Color.blue
    var foregroundColor = Color.white
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 35)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
