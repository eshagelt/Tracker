//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Анастасия on 08.02.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    var placeholder = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        navigationItem.title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        placeholder = EmptyTablePlaceholder(type: .statistics, frame: view.safeAreaLayoutGuide.layoutFrame)
        view.addSubview(placeholder)
    }

}
