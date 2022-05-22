//
//  SearchResult.swift
//  Webtrotter
//
//  Created by 堅書 on 2022/05/22.
//

import Foundation

infix operator ==

struct SearchResult: Codable {
    var title: String = ""
    var description: String = ""
    var link: String = ""
    
    func hasAllValues() -> Bool {
        if title != "" && description != "" && link != "" {
            return true
        }
        return false
    }
    
    static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
        let equalTitles: Bool = lhs.title.trimmingCharacters(in: .whitespacesAndNewlines) == rhs.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let equalDescriptions: Bool = lhs.description.trimmingCharacters(in: .whitespacesAndNewlines) == rhs.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let equalLinks: Bool = lhs.link.trimmingCharacters(in: .whitespacesAndNewlines) == rhs.link.trimmingCharacters(in: .whitespacesAndNewlines)
        return equalTitles && equalDescriptions && equalLinks
            
    }
    
}
