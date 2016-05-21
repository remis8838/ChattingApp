//
//  ViewController.swift
//  ChattingApp
//
//  Created by Master on 5/16/16.
//  Copyright © 2016 Master. All rights reserved.
//

import UIKit
import CoreData


class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate{

//    var messages: [Message]?
    
    lazy var fetchResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Friend")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "lastMessage != nil")
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
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
    
    
    private let cellID = "cellID"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.hidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Recent"
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.alwaysBounceVertical = true
        collectionView?.registerClass(MsgCell.self, forCellWithReuseIdentifier: cellID)
        //
        setupData()
        do{
            try fetchResultsController.performFetch()
        }catch let err{
            print(err)
        }
        //Adding mark
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Mark", style: .Plain, target: self, action: #selector(addMark))
    }
    //method 
    func addMark(){
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let mark = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
        mark.name = "Mark Zuckerberg"
        mark.profileImageName = "zuckprofile"
        let markMsg = "Hello, my name is Mark. Nice to meet you..."
        FriendsController.createMessageWithText(markMsg, friend: mark, minutesAgo: 5, context: context)
        //Bill gates
        let bill = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
        mark.name = "Bill Gates"
        mark.profileImageName = ""
        let billMsg = "Hello, I like Windows very much."
        FriendsController.createMessageWithText(billMsg, friend: bill, minutesAgo: 1, context: context)
    }
    
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchResultsController.sections?[0].numberOfObjects{
            return count
        }
        return 0
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! MsgCell
        
        let friend = fetchResultsController.objectAtIndexPath(indexPath) as! Friend
        
        cell.message = friend.lastMessage
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.view.frame.width, 100)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let friend = fetchResultsController.objectAtIndexPath(indexPath) as! Friend
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        
        controller.friend = friend
        navigationController?.pushViewController(controller, animated: true)
    }
    
}


class MsgCell: BaseCell {
    
    override var highlighted: Bool{
        didSet{
            backgroundColor = highlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1): UIColor.whiteColor()
            nameLabel.textColor = highlighted ? UIColor.whiteColor(): UIColor.blackColor()
            timeLabel.textColor = highlighted ? UIColor.whiteColor(): UIColor.blackColor()
            msgLabel.textColor = highlighted ? UIColor.whiteColor(): UIColor.blackColor()
        }
    }
    var message: Message?{
        didSet{
            nameLabel.text = message?.friend?.name
            msgLabel.text = message?.text
            if let profileImageName = message?.friend?.profileImageName{
                profileImageView.image = UIImage(named: profileImageName)
                hasReadImageView.image = UIImage(named: profileImageName)
            }
            message?.text = message?.text
            if let date = message?.date{
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                let elapsedTimeInSeconds = NSDate().timeIntervalSinceDate(date)
                let secInDay: NSTimeInterval = 60*60*24
                if elapsedTimeInSeconds > 7 * secInDay{
                    dateFormatter.dateFormat = "MM/dd/yy"
                }else if elapsedTimeInSeconds > secInDay{
                    dateFormatter.dateFormat = "EEE"
                }
                timeLabel.text = dateFormatter.stringFromDate(date)
            }
            
        }
    }
    //Profile image
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.image = UIImage(named: "zuckprofile")
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        return imageView
    }()
    // Seperator line
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark Zuckerburg"
        label.font = UIFont.systemFontOfSize(20)
        return label
    }()
    let msgLabel: UILabel = {
        let label = UILabel()
        label.text = "Your friends message and something else..."
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(14)
        return label
    }()
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:05 PM"
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(16)
        label.textAlignment = .Right
        return label
    }()
    let hasReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.image = UIImage(named: "zuckprofile")
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        return imageView
    }()
    
    
    override func setupViews(){
        
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        addConstraintWithFormat("H:|-12-[v0(68)]", views: profileImageView)
        addConstraintWithFormat("V:[v0(68)]", views: profileImageView)
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        
        
        addSubview(dividerLineView)
        dividerLineView.translatesAutoresizingMaskIntoConstraints = false
        addConstraintWithFormat("H:|-82-[v0]|", views: dividerLineView)
        addConstraintWithFormat("V:[v0(1)]|", views: dividerLineView)
        
        
        setupContainerView()
        
        
        
        
    }
    private func setupContainerView(){
        let containerView = UIView()
        
        addSubview(containerView)
        addConstraintWithFormat("H:|-90-[v0]|", views: containerView)
        addConstraintWithFormat("V:[v0(50)]", views: containerView)
        
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(msgLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        containerView.addConstraintWithFormat("H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        containerView.addConstraintWithFormat("V:|[v0][v1(24)]|", views: nameLabel, msgLabel)
        
        
        containerView.addConstraintWithFormat("H:|[v0]-8-[v1(20)]-12-|", views: msgLabel, hasReadImageView)
        containerView.addConstraintWithFormat("V:|[v0(24)]", views: timeLabel)
        containerView.addConstraintWithFormat("V:[v0(20)]|", views: hasReadImageView)
        
    }
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
    }
}

extension UIView{
    func addConstraintWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        
        for (index, view) in views.enumerate(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}























