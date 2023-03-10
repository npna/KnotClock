//
//  HiddenDaily.swift
//  KnotClock
//
//  Created by NA on 3/9/23.
//

import Foundation

struct HideDaily<HiddenDailyList: Codable> {
    var list: [HiddenDailyList]
}

struct HiddenDailyItem: Codable {
    var id: UUID = UUID()
    var ymd: Int = 2100_01_01
}

extension HideDaily: RawRepresentable {
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self.list),
              let json = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        
        return json
    }

    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([HiddenDailyList].self, from: data)
        else {
            return nil
        }
        
        self.list = decoded
    }
}
