//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Анастасия on 08.02.2024.
//

import UIKit

final class TrackersViewController: UIViewController {

    private var trackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private var trackerCollection = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewLayout())
    
    private var filterButton = UIButton()
    private var placeholder = UIView()
    private let datePicker = UIDatePicker()
    private let search = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NewTrackerDelegate.shared.trackersVC = self
        
        NotificationCenter.default.addObserver(forName: TrackerStorageService.didChageCompletedTrackers, object: nil, queue: .main, using: { [weak self] _ in
            guard let self else { return }
            
            completedTrackers = TrackerStorageService.shared.getRecords(date: datePicker.date)
        })
        
        view.backgroundColor = .systemBackground
        
        updateCategories()
        setupNavigationBar()
        setupCollection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkVisibility()
    }
    
    func checkVisibility() {
        let frame = view.safeAreaLayoutGuide.layoutFrame
        if let searchText = search.searchBar.text,
           !searchText.isEmpty {
            filterButton.isHidden = true
            placeholder.removeFromSuperview()
            placeholder = EmptyTablePlaceholder(type: .search, frame: frame)
            view.addSubview(placeholder)
        } else {
            filterButton.isHidden = visibleCategories.isEmpty
            placeholder.removeFromSuperview()
            placeholder = EmptyTablePlaceholder(type: .tracker, frame: frame)
            view.addSubview(placeholder)
        }
        
        placeholder.isHidden = !visibleCategories.isEmpty
        trackerCollection.isHidden = visibleCategories.isEmpty
    }
    
    
    @objc func addNewTracker() {
        self.show(UINavigationController(rootViewController: TrackerTypeChoiceViewController()), sender: nil)
    }
    
    @objc func filterButtonTapped() {
        show(UINavigationController(rootViewController: FilterViewController()), sender: nil)
    }
    
    @objc func updateForDay() {
        visibleCategories = []
        updateCategories()
        let nonEmptyCategories = categories.filter {
            !$0.trackers.isEmpty
        }

        for category in nonEmptyCategories {
            let calendar = Calendar(identifier: .gregorian)
            let weekday = calendar.component(.weekday, from: datePicker.date)
            let todayTrackers = category.trackers.filter {
                let trackerWeekdays = $0.timetable.map { $0.convertToCalendarWeekday() }
                return trackerWeekdays.contains(weekday)
            }
            visibleCategories.append(TrackerCategory(name: category.name, trackers: todayTrackers))
        }

        visibleCategories = visibleCategories.filter {
            !$0.trackers.isEmpty
        }
        completedTrackers = TrackerStorageService.shared.getRecords(date: datePicker.date)
        checkVisibility()
        trackerCollection.reloadData()
    }
    
    @objc func updateVisibleCategories() {
        updateCategories()
        visibleCategories = []
        
        let nonEmptyCategories = categories.filter {
            !$0.trackers.isEmpty
        }
        
        for category in nonEmptyCategories {
            let calendar = Calendar(identifier: .gregorian)
            let weekday = calendar.component(.weekday, from: datePicker.date)
            let todayTrackers = category.trackers.filter {
                let trackerWeekdays = $0.timetable.map { $0.convertToCalendarWeekday() }
                return trackerWeekdays.contains(weekday)
            }
            visibleCategories.append(TrackerCategory(name: category.name, trackers: todayTrackers))
        }
        
        if let searchText = search.searchBar.text,
           !searchText.isEmpty {
            let searchResults: [TrackerCategory] = visibleCategories.map {
                let trackers = $0.trackers.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText)
                }
                return TrackerCategory(name: $0.name, trackers: trackers)
            }
            visibleCategories = searchResults
        }
        
        visibleCategories = visibleCategories.filter {
            !$0.trackers.isEmpty
        }
        
        completedTrackers = TrackerStorageService.shared.getRecords(date: datePicker.date)
        
        checkPlaceholderVisibility()
        trackerCollection.reloadData()
    }
    
    func updateCategories() {
        categories = TrackerStorageService.shared.getAllCategories()
    }
    
    func newTrackerAdded() {
        categories = TrackerStorageService.shared.getAllCategories()
        updateVisibleCategories()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "AddTracker"), style: .plain, target: self, action: #selector(addNewTracker))
        
        datePicker.locale = Locale(identifier: "ru_DE_POSIX")
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.calendar.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        let dateButton = UIBarButtonItem(customView: datePicker)
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(updateVisibleCategories), for: .valueChanged)
        datePicker.tintColor = .AppColors.blue
        navigationItem.rightBarButtonItem = dateButton
        
        search.hidesNavigationBarDuringPresentation = false
        search.searchBar.placeholder = "Поиск"
        search.searchBar.delegate = self
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.tintColor = .label
    }
    
    func setupCollection() {
        let frame = view.safeAreaLayoutGuide.layoutFrame
        let layout = UICollectionViewFlowLayout()
        trackerCollection = UICollectionView(frame: frame, collectionViewLayout: layout)
        trackerCollection.translatesAutoresizingMaskIntoConstraints = false
        trackerCollection.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        trackerCollection.delegate = self
        trackerCollection.dataSource = self
        trackerCollection.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        trackerCollection.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "tracker")
        view.addSubview(trackerCollection)
        trackerCollection.reloadData()
        
        filterButton = CustomButton(type: .system)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = .AppColors.blue
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.titleLabel?.font = UIFont(name: "SFPro-Regular", size: 17)
        view.addSubview(filterButton)
        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    private func checkPlaceholderVisibility() {
        let frame = view.safeAreaLayoutGuide.layoutFrame
        if let searchText = search.searchBar.text,
           !searchText.isEmpty {
            filterButton.isHidden = true
            placeholder.removeFromSuperview()
            placeholder = EmptyTablePlaceholder(type: .search, frame: frame)
            view.addSubview(placeholder)
        } else {
            filterButton.isHidden = visibleCategories.isEmpty
            placeholder.removeFromSuperview()
            placeholder = EmptyTablePlaceholder(type: .tracker, frame: frame)
            view.addSubview(placeholder)
        }
        
        placeholder.isHidden = !visibleCategories.isEmpty
        trackerCollection.isHidden = visibleCategories.isEmpty
    }
    
    
}

extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 39 ) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 46)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tracker", for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        completedTrackers = TrackerStorageService.shared.getRecords(date: datePicker.date)
        cell.configureCell(with: tracker, date: datePicker.date)
        cell.delegate = self
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerHeader else {
                return UICollectionReusableView()
            }
            header.label.text = visibleCategories[indexPath.section].name
            return header
        } else {
            return UICollectionReusableView()
        }
    }
}

extension TrackersViewController: UISearchBarDelegate {

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        updateVisibleCategories()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateVisibleCategories()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateVisibleCategories()
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func updateRecords(with record: TrackerRecord, completion: (Bool) -> Void) {
        completedTrackers = TrackerStorageService.shared.getRecords(date: datePicker.date)
        let completedID = completedTrackers.filter {
            $0.trackerID == record.trackerID
        }
        let isRecorded = !completedID.isEmpty
        if !isRecorded {
            TrackerStorageService.shared.addRecord(record)
        } else {
            TrackerStorageService.shared.removeRecord(record)
        }
        completion(!isRecorded)
    }
}
