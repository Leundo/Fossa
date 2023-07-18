//
//  MultipleTextFieldController.swift
//  Fossa
//
//  Created by Undo Hatsune on 2023/07/18.
//

import Foundation
import UIKit


public enum MultipleTextFieldItem: BudItem {
    case input(value: String?, id: Int)
    case add
}


public class MultipleTextFieldViewModel: BudViewModel<MultipleTextFieldItem> {
    var values: [String?]
    weak var delegate: MultipleTextFieldControllerDelegate?
    
    init(values: [String?]) {
        if values.isEmpty {
            self.values = [nil]
        } else {
            self.values = values
        }
        super.init()
    }
    
    override public func getSections() -> [Int] {
        return [0]
    }
    
    override public func getItems(section: Int) -> [MultipleTextFieldItem] {
        return values.enumerated().map { .input(value: $0.1, id: $0.0) } + [.add]
    }
    
    override public func getAccessories(indexPath: IndexPath, item: MultipleTextFieldItem) -> [UICellAccessory] {
        switch item {
        case let .input(_, id):
            return [.delete(displayed: .always, actionHandler: { [weak self] in
                self?.didDeleteItem(id: id)
            })]
        case .add:
            return [.insert(displayed: .always)]
        }
    }
    
    private func didDeleteItem(id: Int) {
        values.remove(at: id)
        delegate?.updateDataSource(animated: true)
    }
    
    func addNewValue() {
        values.append(nil)
    }
}

public class MultipleTextFieldController: BudController<MultipleTextFieldViewModel, MultipleTextFieldItem>, MultipleTextFieldControllerDelegate {
    var backingHook: ([String]) -> Void
    var navigationTitle: String?
    var placeholder: String?
    var addingTip: String?
    
    public init(_ initialValues: [String], title: String? = nil, placeholder: String? = nil, addingTip: String? = nil, backingHook: @escaping ([String]) -> Void) {
        self.backingHook = backingHook
        self.navigationTitle = title
        self.placeholder = placeholder
        self.addingTip = addingTip
        super.init(viewModel: MultipleTextFieldViewModel(values: initialValues))
        viewModel.delegate = self
    }
    
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewWillDisappear(_ animated: Bool) {
        // https://stackoverflow.com/questions/27713747/execute-action-when-back-bar-button-of-uinavigationcontroller-is-pressed
        backingHook(viewModel.values.compactMap{$0})
    }
    
    // MARK: - Layout
    public override func configureNavigation() {
        super.configureNavigation()
        navigationItem.title = navigationTitle
    }
    
    public override func createContentConfiguration(for cell:  UICollectionViewListCell, with item: MultipleTextFieldItem, at indexPath: IndexPath) -> UIContentConfiguration? {
        switch item {
        case let .input(value, id):
            return TextFieldContentConfiguration.with { [weak self] in
                $0.moniker = String(id)
                $0.value = value
                $0.placeholder = self?.placeholder
            }.onChange { [weak self] moniker, value in
                if let moniker = moniker, let id = Int(moniker) {
                    if let value = value, !value.isEmpty {
                        self?.viewModel.values[id] = value
                    } else {
                        self?.viewModel.values[id] = nil
                    }
                }
            }
        case .add:
            return TextFieldContentConfiguration.with { [weak self] in
                $0.value = self?.addingTip
                $0.textColor = .tintColor
                $0.isEnabled = false
            }
        }
    }
    
    
    // MARK: - Collcetion
    public override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .add:
            return true
        default:
            return false
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if item == .add {
            viewModel.addNewValue()
            updateDataSource(animated: true)
        }
    }
}


public protocol MultipleTextFieldControllerDelegate: AnyObject {
    func updateDataSource(animated: Bool)
}
