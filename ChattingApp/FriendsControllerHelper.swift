//
//  FriendsControllerHelper.swift
//  ChattingApp
//
//  Created by Master on 5/16/16.
//  Copyright © 2016 Master. All rights reserved.
//

import UIKit
import CoreData


extension FriendsController{
    
    func clearData(){
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let context = delegate?.managedObjectContext{
            do{
                let entityNames = ["Friend", "Message"]
                for entityName in entityNames{
                    let fetchRequest = NSFetchRequest(entityName: entityName)
                    let objects = try(context.executeFetchRequest(fetchRequest)) as? [NSManagedObject]
                    
                    for object in objects!{
                        context.deleteObject(object)
                    }
                }
                try(context.save())
            } catch let err{
                print(err)
            }
        }
    }
    func setupData(){
        
        clearData()
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let context = delegate?.managedObjectContext{
            let mark = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
            mark.name = "Mark Zuckerberg"
            mark.profileImageName = "zuckprofile"
            let markMsg = "Hello, my name is Mark. Nice to meet you..."
            FriendsController.createMessageWithText(markMsg, friend: mark, minutesAgo: 3, context: context)
            let markMsg1 = "Hello"
            FriendsController.createMessageWithText(markMsg1, friend: mark, minutesAgo: 1, context: context)
            //
            createSteveMessagesWithContext(context)
            
            let donald = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
            donald.name = "Donald Trump"
            donald.profileImageName = "donald_profile"
            
            let donaldMsg = "You're fired"
            FriendsController.createMessageWithText(donaldMsg, friend: donald, minutesAgo: 1, context: context)
            //
            let gandhi = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
            gandhi.name = "Mahatma Gandhi"
            gandhi.profileImageName = "gandhi_profile"
            let gandhiMsg = "Love, peace and Joy,"
            FriendsController.createMessageWithText(gandhiMsg, friend: gandhi, minutesAgo: 60*24, context: context)
            //
            let hillary = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
            hillary.name = "Hillary Clinton"
            hillary.profileImageName = "hillary_profile"
            let hillaryMsg = "Please vote for me, you did for Billy!"
            FriendsController.createMessageWithText(hillaryMsg, friend: hillary, minutesAgo: 60*24*8, context: context)
            do{
                try(context.save())
            }catch let err{
                print(err)
            }
//            messages = [message, steveMsg]
        }
        
//        loadData()
    }
    //Steve Jobs 
    private func createSteveMessagesWithContext(context: NSManagedObjectContext){
        //Steve Jobs
        let steve = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
        steve.name = "Steve Jobs"
        steve.profileImageName = "steve_profile"
        
        FriendsController.createMessageWithText("Good morning...", friend: steve, minutesAgo: 3, context: context)
        FriendsController.createMessageWithText("Hello how are you? Hope you are having a good morning!", friend: steve, minutesAgo: 2, context: context)
        FriendsController.createMessageWithText("Are you interested in buying apple device? We have a wide variety of apple devices that will suit your purchase with us.", friend: steve, minutesAgo: 1, context: context)
        //responds message
        FriendsController.createMessageWithText("Yes, totally looking to buy an iPhone 7.", friend: steve, minutesAgo: 1, context: context, isSender: true)
        FriendsController.createMessageWithText("Totally understand that you want the new iPhone 7, but you'll have to wait until september for the new release, Sorry but thats just how apple likes to do things.", friend: steve, minutesAgo: 1, context: context)
        FriendsController.createMessageWithText("Absolutely, I'll just use my gigantic iPhone 6 Plus until then!!!", friend: steve, minutesAgo: 1, context: context, isSender: true)
        
        
    }
    
    static func createMessageWithText(text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false) -> Message{
        let message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        message.friend = friend
        message.text = text
        message.date = NSDate().dateByAddingTimeInterval(-minutesAgo*60)
        message.isSender = NSNumber(bool: isSender)
        friend.lastMessage = message
        return message
    }
    
    
//    func loadData(){
//        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
//        if let context = delegate?.managedObjectContext{
//            messages = [Message]()
//            if let friends = fetchFriend(){
//                for friend in friends{
//                    let fetchRequest = NSFetchRequest(entityName: "Message")
//                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
//                    fetchRequest.fetchLimit = 1
//                    
//                    
//                    do{
//                        let fetchedMsg = try(context.executeFetchRequest(fetchRequest)) as? [Message]
//                        messages?.appendContentsOf(fetchedMsg!)
//                    } catch let err{
//                        print(err)
//                    }
//                }
//            }
//            messages = messages?.sort({$0.date!.compare($1.date!) == .OrderedDescending})
//        }
//    }
//    private func fetchFriend() -> [Friend]?{
//        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
//        if let context = delegate?.managedObjectContext{
//            let request = NSFetchRequest(entityName: "Friend")
//            
//            do{
//                return try context.executeFetchRequest(request) as? [Friend]
//            } catch let err{
//                print(err)
//            }
//        }
//        return nil
//    }
}



