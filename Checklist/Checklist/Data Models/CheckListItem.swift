//
//  CheckListItem.swift
//  Checklist
//
//  Created by dibs on 01/03/23.
//

import Foundation
import UserNotifications

class CheckListItem : Codable{
    var text = ""
    var checked = false
    var dueDate = Date()
    var shouldRemind = false
    var itemID = -1
    
    init(){
        itemID = DataModel.nextChecklistItemID()
    }
    
    deinit{
        removeNotification()
    }
    //MARK:- Notification
    
    func scheduleNotification(){
        removeNotification()
        if shouldRemind && dueDate > Date(){
            let content = UNMutableNotificationContent()
            content.title = "Reminder"
            content.body = text
            content.sound = UNNotificationSound.default
            
            let calender = Calendar(identifier: .gregorian)
            let component = calender.dateComponents([.year,.month,.day,.hour,.minute], from: dueDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request)
            
            print( "Scheduled: \(request) for itemID: \(itemID)")
        }
    }
    
    func removeNotification(){
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
    }
    
}
