//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Анастасия on 02.03.2024.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func updateRecords(with record: TrackerRecord, completion: (Bool) -> Void)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    private var trackerView = UIView()
    private var emojiLabel = UILabel()
    private var titleLabel = UILabel()
    private var isRecorded: Bool = false {
        didSet {
            incrementButton.setImage(buttonImage(), for: .normal)
            incrementButton.alpha = isRecorded ? 0.3 : 1
        }
    }
    
    private lazy var buttonImage = { [weak self] in
        guard let self else { return UIImage() }
        var image = UIImage(named: self.isRecorded ? "Recorded" : "Plus") ?? UIImage()
        return image
    }
    
    private var allRecords: [TrackerRecord] = []
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var managementView = UIView()
    private var incrementButton = UIButton()
    private var daysLabel = UILabel()
    private var cellDate = Date()
    
    private var cellTracker = Tracker(singleEventTitle: "", emoji: "", color: .AppColors.gray)
    
    override func prepareForReuse() {
        daysLabel.text = ""
        daysLabel.removeFromSuperview()
        incrementButton.removeFromSuperview()
    }
    
    private func checkIfRecorded() {
        allRecords = TrackerStorageService.shared.getRecords(for: cellTracker.id)

        var isNowRecorded = false

        for record in allRecords {
            let calendar = Calendar.current
            if calendar.isDate(cellDate, inSameDayAs: record.date) {
            isNowRecorded = true
            }
        }
        isRecorded = isNowRecorded
    }
    
    func configureCell(with tracker: Tracker, date: Date) {
        cellTracker = tracker
        cellDate = date
        checkIfRecorded()
        
        addSubview(trackerView)
        trackerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            trackerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackerView.topAnchor.constraint(equalTo: topAnchor)
        ])
        trackerView.layer.cornerRadius = 16
        trackerView.clipsToBounds = true
        trackerView.backgroundColor = tracker.color
        
        trackerView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12)
        ])
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true
        emojiLabel.backgroundColor = .AppColors.background
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.textAlignment = .center
        emojiLabel.text = tracker.emoji
        
        trackerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12)
        ])
        titleLabel.font = .boldSystemFont(ofSize: 12)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .AppColors.white
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 12)
        titleLabel.text = tracker.title
        
        addSubview(managementView)
        managementView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            managementView.topAnchor.constraint(equalTo: trackerView.bottomAnchor),
            managementView.bottomAnchor.constraint(equalTo: bottomAnchor),
            managementView.leadingAnchor.constraint(equalTo: leadingAnchor),
            managementView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        incrementButton = UIButton(type: .system)
        incrementButton.setImage(buttonImage(), for: .normal)
        managementView.addSubview(incrementButton)
        incrementButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            incrementButton.heightAnchor.constraint(equalToConstant: 34),
            incrementButton.widthAnchor.constraint(equalToConstant: 34),
            incrementButton.topAnchor.constraint(equalTo: managementView.topAnchor, constant: 6),
            incrementButton.trailingAnchor.constraint(equalTo: managementView.trailingAnchor, constant: -12)
        ])
        incrementButton.backgroundColor = tracker.color
        incrementButton.tintColor = .AppColors.white
        incrementButton.clipsToBounds = true
        incrementButton.layer.cornerRadius = 17
        incrementButton.addTarget(self, action: #selector(incrementButtonTapped), for: .touchUpInside)
        incrementButton.showsTouchWhenHighlighted = true
        
        daysLabel = UILabel()
        managementView.addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysLabel.leadingAnchor.constraint(equalTo: managementView.leadingAnchor, constant: 12),
            daysLabel.trailingAnchor.constraint(equalTo: incrementButton.leadingAnchor, constant: -8),
            daysLabel.topAnchor.constraint(equalTo: managementView.topAnchor, constant: 8),
            daysLabel.bottomAnchor.constraint(equalTo: incrementButton.bottomAnchor)
        ])
        daysLabel.font = UIFont(name: "SFPro-Medium", size: 12)
        updateDay()
    }
    
    @objc func incrementButtonTapped() {
        let record = TrackerRecord(trackerID: cellTracker.id, date: cellDate)
        delegate?.updateRecords(with: record) { [weak self] newRecStatus in
            self?.isRecorded = newRecStatus
        }
        updateDay()
    }
    
    private func updateDay() {
        let daysCount = TrackerStorageService.shared.getRecords(for: cellTracker.id)
        daysLabel.text = dayFormatter.string(from: DateComponents(day: daysCount.count))
    }
    
    
    
}
