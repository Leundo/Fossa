//
//  SwipeableControllerDelegate.swift
//  Fossa
//
//  Created by Undo Hatsune on 2023/07/17.
//

import Foundation
import UIKit


public enum SwipingDirection: Hashable {
    case leading
    case trailing
}


public protocol ActionSwipeable {
    var image: UIImage? { get }
    var style: UIContextualAction.Style { get }
    var title: String { get }
    var backgroundColor: UIColor { get }
}

public protocol SwipeableControllerDelegate: AnyObject {
    func swipe(direction: SwipingDirection, kind: any ActionSwipeable, indexPath: IndexPath, completion: @escaping (Bool) -> Void)
    func createSwipeConfigurationProvider(direction: SwipingDirection) -> (IndexPath) -> UISwipeActionsConfiguration
    func createContextualAction(direction: SwipingDirection, indexPath: IndexPath, kind: any ActionSwipeable) -> UIContextualAction
    func getSwipeActionKinds(direction: SwipingDirection, indexPath: IndexPath) -> [any ActionSwipeable]
}


extension SwipeableControllerDelegate {
    public func swipe(direction: SwipingDirection, kind: any ActionSwipeable, indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        
    }
    
    public func createSwipeConfigurationProvider(direction: SwipingDirection) -> (IndexPath) -> UISwipeActionsConfiguration {
        return { [unowned self] (indexPath: IndexPath) in
            let kinds = self.getSwipeActionKinds(direction: direction, indexPath: indexPath)
            return UISwipeActionsConfiguration(actions: kinds.map {self.createContextualAction(direction: direction, indexPath: indexPath, kind: $0)})
        }
    }
    
    public func getSwipeActionKinds(direction: SwipingDirection, indexPath: IndexPath) -> [any ActionSwipeable] {
        return []
    }
    
    public func createContextualAction(direction: SwipingDirection, indexPath: IndexPath, kind: any ActionSwipeable) -> UIContextualAction {
        let action = UIContextualAction(style: kind.style, title: nil) {
            [weak self] action, view, completion in
            self?.swipe(direction: direction, kind: kind, indexPath: indexPath, completion: completion)
        }
        action.image = kind.image
        action.backgroundColor = kind.backgroundColor
        action.title = kind.title
        return action
    }
}
