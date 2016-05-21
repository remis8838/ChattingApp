//
//  CustomTabBarController.swift
//  ChattingApp
//
//  Created by Master on 5/17/16.
//  Copyright © 2016 Master. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup the viewControllers
        //RecentMessageViewController
        let layout = UICollectionViewFlowLayout()
        let friendController = FriendsController(collectionViewLayout: layout)
        let recentMsgController = UINavigationController(rootViewController: friendController)
        recentMsgController.tabBarItem.title = "Recent"
        recentMsgController.tabBarItem.image = UIImage(named: "recent")
        //
        
        let callsVC = createDummyNavigationController("Calls", imageName: "calls")
        let peopleVC = createDummyNavigationController("People", imageName: "people")
        let groupsVC = createDummyNavigationController("Groups", imageName: "groups")
        let settingVC = createDummyNavigationController("Setting", imageName: "settings")
        viewControllers = [recentMsgController, callsVC, groupsVC, peopleVC, settingVC]
        
    }
    private func createDummyNavigationController(title: String, imageName: String) -> UINavigationController{
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }

}
