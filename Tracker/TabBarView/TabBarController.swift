//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Анастасия on 08.02.2024.
//

import UIKit

final class TabBarController: UITabBarController {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        
        let trackersVC = UINavigationController(rootViewController: TrackersViewController())
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "tabBar_trackers"), selectedImage: nil)
        trackersVC.navigationController?.navigationBar.prefersLargeTitles = true
        trackersVC.navigationItem.largeTitleDisplayMode = .never

        
        let statVC = UINavigationController(rootViewController: StatisticsViewController())
        statVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "tabBar_statistics"), selectedImage: nil)
        
        viewControllers = [trackersVC, statVC]

        tabBar.tintColor = .AppColors.blue
        

        let dividerView = UIView(frame: CGRect(x: tabBar.frame.minX, y: 0, width: tabBar.frame.width, height: 0.5))
        dividerView.backgroundColor = UIColor.AppColors.gray
        tabBar.addSubview(dividerView)
    }
}

