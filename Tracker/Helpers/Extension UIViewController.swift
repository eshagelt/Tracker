//
//  Extension UIViewController.swift
//  Tracker
//
//  Created by Анастасия on 18.03.2024.
//

import UIKit

extension UIViewController {
    func addTapGestureToHideKeyboard(for editedView: UIView) {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(editedView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}
