//
//  TabBarController.swift
//  ParkEasy
//
//  Created by Emre Tuğ on 2.11.2023.
//

import UIKit

class MyTabBarController: UITabBarController {

   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true

        tabBar.backgroundColor = .white
        let firstViewController = HomeViewController()
        let secondViewController = HistoryViewController()
        
        firstViewController.tabBarItem =  UITabBarItem(title: LocalizedString.home, image: UIImage(systemName: "house.fill"), tag: 0)
        secondViewController.tabBarItem = UITabBarItem(title:LocalizedString.history,image: UIImage(systemName: "clock.fill"), tag: 1)
        
        let controllers = [firstViewController, secondViewController]
        viewControllers = controllers
    }
    class LocalizedString{
        static let home = NSLocalizedString("tabbarcontroller.home", comment: "")
        static let history = NSLocalizedString("tabbarcontroller.history", comment: "")

    }
}


#Preview{
    MyTabBarController()
}
