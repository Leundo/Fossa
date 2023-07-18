//
//  BudController.swift
//  Fossa
//
//  Created by Undo Hatsune on 2023/07/17.
//

import Foundation
import UIKit


public protocol BudItem: Hashable {}


open class BudViewModel<Item: BudItem> {
    public init() {}
    
    open func getSections() -> [Int] {
        return []
    }
    
    open func getItems(section: Int) -> [Item] {
        return []
    }
    
    open func getAccessories(indexPath: IndexPath, item: Item) -> [UICellAccessory] {
        return []
    }
    
    open func shouldAddSearchBar() -> Bool { return false }
}


open class BudController<ViewModel: BudViewModel<Item>, Item: BudItem>: UIViewController, UICollectionViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    open var viewModel: ViewModel
    public var collectionView: UICollectionView!
    public var dataSource: DataSource!
    public var searchController: UISearchController?
    
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureHierarchy()
        configureDataSource()
    }
    
    open override func viewWillAppear(_ animated: Bool) {}
    
    // MARK: - Layout
    open func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    open func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.allowsMultipleSelectionDuringEditing = true
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
    
    open func configureNavigation() {
        if viewModel.shouldAddSearchBar() {
            searchController = UISearchController(searchResultsController: nil)
            searchController?.delegate = self
            searchController?.searchBar.delegate = self
            navigationItem.searchController = searchController
        }
        setNormalLeftNavigationItems()
        setNormalRightNavigationItems()
    }
    
    open func setNormalLeftNavigationItems() {}
    open func setNormalRightNavigationItems() {}
    open func setEditingLeftNavigationItems() {}
    open func setEditingRightNavigationItems() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing))]
    }
    
    
    // MARK: - Interaction
    open override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        collectionView.isEditing = editing
        collectionView.allowsMultipleSelection = editing
        
        navigationController?.setToolbarHidden(!editing, animated: true)
        if editing {
            setEditingLeftNavigationItems()
            setEditingRightNavigationItems()
        } else {
            setNormalLeftNavigationItems()
            setNormalRightNavigationItems()
        }
    }
    
    @objc open func endEditing() {
        setEditing(false, animated: true)
    }
    
    open func createContentConfiguration(for cell:  UICollectionViewListCell, with item: Item, at indexPath: IndexPath) -> UIContentConfiguration? {
        return nil
    }
    
    
    // MARK: - DataSource
    public typealias DataSource = UICollectionViewDiffableDataSource<Int, Item>
    public typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>
    public typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>
    
    
    open func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [weak self] cell, indexPath, item in
            cell.contentConfiguration = self?.createContentConfiguration(for: cell, with: item, at: indexPath)
            cell.accessories = self?.viewModel.getAccessories(indexPath: indexPath, item: item) ?? []
        }
        dataSource = DataSource(collectionView: collectionView) {
            collectionView, indexPath, item -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        updateDataSource(animated: false)
    }
    
    public func updateDataSource(animated: Bool = true) {
        for section in viewModel.getSections() {
            var sectionSnapshot = SectionSnapshot()
            sectionSnapshot.append(viewModel.getItems(section: section))
            dataSource.apply(sectionSnapshot, to: section, animatingDifferences: animated)
        }
    }
    
    // MARK: - Collection
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return true }
    
    open func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool { return true }
    
    open func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool { return true }
    
    open func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {}
    
    
    // MARK: - Search
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {}
    
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {}
    
    
    // MARK: - TextField
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newLength = text.count + string.count - range.length
        return newLength <= 100
    }
}
