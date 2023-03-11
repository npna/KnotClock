//
//  ConditionalModifier.swift
//  KnotClock
//
//  Created by NA on 3/11/23.
//

import SwiftUI

extension View {
    @ViewBuilder
    func conditionalMofidier<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
