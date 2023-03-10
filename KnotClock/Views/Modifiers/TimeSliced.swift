//
//  TimeSliced.swift
//  KnotClock
//
//  Created by NA on 2/27/23.
//

import SwiftUI

struct TimeSliced: ViewModifier {
    let minWidth: CGFloat
    let font: Font
    
    init(_ mode: TimeSlicedMode) {
        minWidth = K.TimeSliced.getMinWidth(mode)
        font = K.TimeSliced.getFont(mode)
    }
    
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: minWidth)
            .font(font)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
    }
}

extension View {
    func timeSliced(_ mode: TimeSlicedMode = .full) -> some View {
        self.modifier(TimeSliced(mode))
    }
}
