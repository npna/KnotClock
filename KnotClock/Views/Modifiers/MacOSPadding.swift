//
//  MacOSPadding.swift
//  KnotClock
//
//  Created by NA on 2/22/23.
//

import SwiftUI

struct MacOSPadding: ViewModifier {
    var edges: Edge.Set = .all
    var length: CGFloat? = nil
    
    func body(content: Content) -> some View {
        #if os(macOS)
        if let length {
            return content.padding(edges, length)
        } else {
            return content.padding(edges)
        }
        #else
        return content
        #endif
    }
}

extension View {
    func macOSPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        self.modifier(MacOSPadding(edges: edges, length: length))
    }
    
    func macOSPadding(_ length: CGFloat? = nil) -> some View {
        self.modifier(MacOSPadding(length: length))
    }
}
