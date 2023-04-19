//
//  Checklist.swift
//  Checklist
//
//  Created by dibs on 04/03/23.
//

import UIKit

class Checklist: NSObject, Codable {
    var name = ""
    var items = [CheckListItem]()
    var iconName = "No Icon"
    
    func countUnCheckedItems() -> Int{
        var count = 0
        for item in items where !item.checked{
            count += 1
        }
        return count
    }
    init(name : String, iconName: String = "No Icon"){
        self.name = name
        self.iconName = iconName
        super.init()
    }
}
