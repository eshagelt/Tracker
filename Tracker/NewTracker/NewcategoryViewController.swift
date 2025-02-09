//
//  NewcategoryViewController.swift
//  Tracker
//
//  Created by Анастасия on 18.03.2024.
//

import UIKit

protocol NewCategoryDelegate: AnyObject {
    func addCategory(_ categoryName: String)
}

final class NewCategoryViewController: UIViewController {
    
    private let textField = TrackerNameField()
    private let doneButton = CustomButton(type: .system)
    
    weak var delegate: NewCategoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Новая категория"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        
        view.backgroundColor = .systemBackground
        setupUI()
        addTapGestureToHideKeyboard(for: textField)
    }
    
    private func setupUI() {
        view.addSubview(textField)
        textField.backgroundColor = .AppColors.gray
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .AppColors.background
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        doneButton.setTitle("Готово", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        doneButton.switchActiveState(isActive: false)
    }
    
    @objc private func textFieldDidChange() {
        var isReady = false
        if let text = textField.text,
           !text.isEmpty {
            isReady = true
        }
        doneButton.switchActiveState(isActive: isReady)
    }
    
    @objc private func done() {
        if let text = textField.text {
            delegate?.addCategory(text)
        }
        dismiss(animated: true)
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

