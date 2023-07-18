////
////  FloretController.swift
////  Fossa
////
////  Created by Undo Hatsune on 2023/07/18.
////
//
//import Foundation
//import UIKit
//
//
//public protocol FloretItem: Hashable {}
//
//
//open class FloretViewModel<Item: FloretItem> {
//    public init() {}
//    
//    open func getSections() -> [Int] {
//        return []
//    }
//    
//    open func getItems(section: Int) -> [Item] {
//        return []
//    }
//    
//    open func getAccessories(indexPath: IndexPath, item: Item) -> [UICellAccessory] {
//        return []
//    }
//    
//    open func shouldAddSearchBar() -> Bool { return false }
//}
//
//
//open class FloretController<ViewModel: FloretViewModel<Item>, Item: FloretItem>: UIViewController, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
//    open var viewModel: ViewModel
//    public var tableView: UITableView!
//    public var dataSource: DataSource!
//    public var searchController: UISearchController?
//    
//    
//    public init(viewModel: ViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    public required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        configureNavigation()
//        configureHierarchy()
//        configureDataSource()
//    }
//    
//    // MARK: - Layout
//    open func createLayout() -> UICollectionViewLayout {
//        let config = UICollectionLayoutListConfiguration(appearance: .plain)
//        return UICollectionViewCompositionalLayout.list(using: config)
//    }
//    
//    open func configureHierarchy() {
//        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
//        tableView.allowsMultipleSelectionDuringEditing = true
//        tableView.delegate = self
//        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        tableView.rowHeight = UITableView.automaticDimension
//        view.addSubview(tableView)
//    }
//    
//    open func configureNavigation() {
//        if viewModel.shouldAddSearchBar() {
//            searchController = UISearchController(searchResultsController: nil)
//            searchController?.delegate = self
//            searchController?.searchBar.delegate = self
//            navigationItem.searchController = searchController
//        }
//        setNormalLeftNavigationItems()
//        setNormalRightNavigationItems()
//    }
//    
//    open func setNormalLeftNavigationItems() {}
//    open func setNormalRightNavigationItems() {}
//    open func setEditingLeftNavigationItems() {}
//    open func setEditingRightNavigationItems() {
//        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing))]
//    }
//    
//    
//    // MARK: - Interaction
//    open override func setEditing(_ editing: Bool, animated: Bool) {
//        super.setEditing(editing, animated: true)
//        tableView.isEditing = editing
//        tableView.allowsMultipleSelection = editing
//        
//        navigationController?.setToolbarHidden(!editing, animated: true)
//        if editing {
//            setEditingLeftNavigationItems()
//            setEditingRightNavigationItems()
//        } else {
//            setNormalLeftNavigationItems()
//            setNormalRightNavigationItems()
//        }
//    }
//    
//    @objc open func endEditing() {
//        setEditing(false, animated: true)
//    }
//    
//    open func createContentConfiguration(for cell: UITableViewCell, with item: Item, at indexPath: IndexPath) -> UIContentConfiguration? {
//        return nil
//    }
//    
//    
//    // MARK: - DataSource
////    public typealias DataSource = UICollectionViewDiffableDataSource<Int, Item>
////    public typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>
////    public typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>
//    
//    public typealias DataSource = UITableViewDiffableDataSource<Int, Item>
//    public typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>
//    public typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>
//    
//    open func configureDataSource() {
//        dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, item in
//            let cell = UITableViewCell()
//            cell.contentConfiguration = self?.createContentConfiguration(for: cell, with: item, at: indexPath)
//            return cell
//        })
//        
//        updateDataSource(animated: false)
//    }
//    
//    public func updateDataSource(animated: Bool = true) {
//        var snapshot = Snapshot()
//        let sections = viewModel.getSections()
//        snapshot.appendSections(sections)
//        for section in sections {
//            snapshot.appendItems(viewModel.getItems(section: section), toSection: section)
//        }
//        dataSource.apply(snapshot, animatingDifferences: animated)
//    }
//    
//    // MARK: - Table
//    
////    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
////    
////    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return true }
////    
////    open func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool { return true }
//    
//    
//    
//    // MARK: - Search
//    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {}
//    
//    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {}
//    
//    
//    // MARK: - TextField
//    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let text = textField.text else { return false }
//        let newLength = text.count + string.count - range.length
//        return newLength <= 100
//    }
//}
