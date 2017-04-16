//
//  parser.swift
//  
//
//  Created by Boocha on 15.04.17.
//
//

import Foundation


func parseColumns(fromLines lines: [String]) -> Dictionary<String, [String]> {
    var columns = Dictionary<String, [String]>()
    
    for header in self.headers {
        let column = self.rows.map { row in row[header] != nil ? row[header]! : "" }
        columns[header] = column
    }
    
    return columns
}

