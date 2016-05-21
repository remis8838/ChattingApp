//
//  ChatLogController.swift
//  ChattingApp
//
//  Created by Master on 5/16/16.
//  Copyright © 2016 Master. All rights reserved.
//

import UIKit
import CoreData

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    
    private let cellID = "cellID"
    var friend: Friend?{
        didSet{
            navigationItem.title = friend?.name
//            messages = friend?.messages?.allObjects as? [Message]
//            messages = messages?.sort({$0.date!.compare($1.date!) == .OrderedAscending})
        }
    }
    
//    var messages: [Message]?
    let msgInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.keyboardType = .Default
        textField.keyboardAppearance = .Light
        return textField
    }()
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", forState: .Normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        button.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
        return button
    }()
    
    func handleSend(){
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
//        let newMsg = FriendsController.createMessageWithText(inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        FriendsController.createMessageWithText(inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        do{
            try context.save()
            inputTextField.text = nil
//            messages?.append(newMsg)
//            let item = messages!.count - 1
//            let insertIndexPath = NSIndexPath(forItem: item, inSection: 0)
//            collectionView?.insertItemsAtIndexPaths([insertIndexPath])
//            collectionView?.scrollToItemAtIndexPath(insertIndexPath, atScrollPosition: .Bottom, animated: true)
            
            
        }catch let err{
            print(err)
        }
    }
    var bottomConstraint: NSLayoutConstraint?
    
    
    func simulate(){
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        FriendsController.createMessageWithText("Here's a text message that was sent a few minutes ago...", friend: friend!, minutesAgo: 0, context: context)
        FriendsController.createMessageWithText("Another message that was received a while ago...", friend: friend!, minutesAgo: 0, context: context)
        do{
            try context.save()
        }catch let err{
            print(err)
        }
    }
    
    lazy var fetchResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "friend.name = %@", self.friend!.name!)
        
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    var blockOperations = [NSBlockOperation]()
    //FetchedResultsController delegate
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if type == .Insert{
            blockOperations.append(NSBlockOperation(block: { 
                self.collectionView?.insertItemsAtIndexPaths([newIndexPath!])
            }))
//            
//            collectionView?.scrollToItemAtIndexPath(newIndexPath!, atScrollPosition: .Bottom, animated: true)
        }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView?.performBatchUpdates({ 
            for operation in self.blockOperations{
                operation.start()
            }
            }, completion: { (completed) in
                let lastItem = self.fetchResultsController.sections![0].numberOfObjects - 1
                let indexPath = NSIndexPath(forItem: lastItem, inSection: 0)
                self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        })
    }
    
    
    override func viewDidLoad() {
        //NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatLogController.handleKeyBoardNotification), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatLogController.handleKeyBoardNotification), name: UIKeyboardWillHideNotification, object: nil)
        super.viewDidLoad()
        //
        do {
            try fetchResultsController.performFetch()
            print(fetchResultsController.sections?[0].numberOfObjects)
        }catch let err{
            print(err)
        }
        
        
        
        //Add simulate button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .Plain, target: self, action: #selector(simulate))
        tabBarController?.tabBar.hidden = true
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(ChatLogMsgCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.keyboardDismissMode = .Interactive
        //Message input view
        view.addSubview(msgInputContainerView)
        view.addConstraintWithFormat("H:|[v0]|", views: msgInputContainerView)
        view.addConstraintWithFormat("V:[v0(48)]", views: msgInputContainerView)
        
        bottomConstraint = NSLayoutConstraint(item: msgInputContainerView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponent()
    }
    func handleKeyBoardNotification(notification: NSNotification){
        if let userInfo = notification.userInfo{
            let keyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
            let isKeyBoardShowing = notification.name == UIKeyboardWillShowNotification
            bottomConstraint?.constant = isKeyBoardShowing ? -keyBoardFrame!.height:0
            UIView.animateWithDuration(0, delay: 0, options: .CurveEaseOut, animations: { 
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    if isKeyBoardShowing{
                        let lastItem = self.fetchResultsController.sections![0].numberOfObjects - 1
                        let indexPath = NSIndexPath(forItem: lastItem, inSection: 0)
                        self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                    }
            })
        }
    }
    private func setupInputComponent(){
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        msgInputContainerView.addSubview(inputTextField)
        msgInputContainerView.addSubview(sendButton)
        msgInputContainerView.addSubview(topBorderView)
        
        
        msgInputContainerView.addConstraintWithFormat("H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        msgInputContainerView.addConstraintWithFormat("V:|[v0]|", views: inputTextField)
        msgInputContainerView.addConstraintWithFormat("V:|[v0]|", views: sendButton)
        
        msgInputContainerView.addConstraintWithFormat("H:|[v0]|", views: topBorderView)
        msgInputContainerView.addConstraintWithFormat("V:|[v0(0.5)]", views: topBorderView)
        
        
    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        inputTextField.endEditing(true)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = fetchResultsController.sections?[0].numberOfObjects{
//        if let count = messages?.count{
            return count
        }
        return 0
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! ChatLogMsgCell
        let msgBody = fetchResultsController.objectAtIndexPath(indexPath) as! Message
        
        
        
        cell.msgTextView.text = msgBody.text
        
        if let msgText = msgBody.text, proImgName = msgBody.friend?.profileImageName{
            
            
            cell.proImgView.image = UIImage(named: proImgName)
            let size = CGSizeMake(self.view.frame.width*0.7+16, 1000)
            let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
            let estimatedFrame = NSString(string: msgText).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(18)], context: nil)
            
            if !msgBody.isSender!.boolValue{
                cell.msgTextView.frame = CGRectMake(48+8, 0, estimatedFrame.width+16, estimatedFrame.height+20)
                cell.msgTextView.textColor = UIColor.blackColor()
                cell.textBubbleView.frame = CGRectMake(48-10, -4, estimatedFrame.width+16+8+16, estimatedFrame.height+20+6)
                cell.proImgView.hidden = false
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.bubbleImageView.image = ChatLogMsgCell.grayBubbleImage
            }else{
                //Outging sending message
                cell.msgTextView.frame = CGRectMake(view.frame.width-estimatedFrame.width-16-8-10, 0, estimatedFrame.width+16, estimatedFrame.height+20)
                cell.msgTextView.textColor = UIColor.whiteColor()
                cell.textBubbleView.frame = CGRectMake(view.frame.width-estimatedFrame.width-16-16-8-10, -4, estimatedFrame.width+16+8+10, estimatedFrame.height+20+6)
                cell.proImgView.hidden = true
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.bubbleImageView.image = ChatLogMsgCell.blueBubbleImage
            }
            
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let msgBody = fetchResultsController.objectAtIndexPath(indexPath) as! Message
        
        if let msgText = msgBody.text{
            let size = CGSizeMake(self.view.frame.width*0.7, 1000)
            let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
            let estimatedFrame = NSString(string: msgText).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(18)], context: nil)
            return CGSizeMake(view.frame.width, estimatedFrame.height+20)
        }
        return CGSizeMake(view.frame.width, 100)
    }
    //
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
    
}

class ChatLogMsgCell: BaseCell {
    
    
    let msgTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFontOfSize(18)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clearColor()
        return textView
    }()
    //Buble
    let textBubbleView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    //Profile image
    let proImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 15
        imgView.layer.masksToBounds = true
        imgView.contentMode = .ScaleAspectFill
        return imgView
    }()
    //Text bubble view
    static let grayBubbleImage = UIImage(named: "bubble_gray")!.resizableImageWithCapInsets(UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).imageWithRenderingMode(.AlwaysTemplate)
    static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImageWithCapInsets(UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).imageWithRenderingMode(.AlwaysTemplate)
    
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(white: 0.95, alpha: 1)
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()        
        addSubview(textBubbleView)
        addSubview(msgTextView)
        addSubview(proImgView)
//        addConstraintWithFormat("H:|[v0]|", views: msgTextView)
//        addConstraintWithFormat("V:|[v0]|", views: msgTextView)
        addConstraintWithFormat("H:|-8-[v0(30)]", views: proImgView)
        addConstraintWithFormat("V:[v0(30)]|", views: proImgView)
    
        proImgView.backgroundColor = UIColor.redColor()
        
        //
        textBubbleView.addSubview(bubbleImageView)
        addConstraintWithFormat("H:|[v0]|", views: bubbleImageView)
        addConstraintWithFormat("V:|[v0]|", views: bubbleImageView)
    }
    
}


