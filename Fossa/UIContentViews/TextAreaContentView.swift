//
//  TextAreaContentView.swift
//  Fossa
//
//  Created by Undo Hatsune on 2023/07/18.
//

import Foundation
import UIKit


public class TextAreaContentView: UIView & UIContentView {
    private let constraintHeight: CGFloat = 2 * Constant.standardHeight
    private let constraintLeftPadding: CGFloat = Constant.standardHorizonPadding
    private let constraintRightPadding: CGFloat = Constant.standardHorizonPadding
    
    private let auxiliaryView = UIView()
    private let textArea = UITextView()
    private var textAreaHeightConstraint: NSLayoutConstraint! = nil
    private var contentViewHeightConstraint: NSLayoutConstraint! = nil
    
    public var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? TextAreaContentConfiguration else { return }
        textArea.text = configuration.value
    }
    
    private func configureLayout() {
        textArea.delegate = self
        textArea.font = UIFont.preferredFont(forTextStyle: .body)
        textArea.backgroundColor = .clear
        textArea.addDoneButtonOnKeyboard()
        
        addSubview(textArea)
        textArea.translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        
        textAreaHeightConstraint = textArea.heightAnchor.constraint(greaterThanOrEqualToConstant: constraintHeight)
        textAreaHeightConstraint.priority = UILayoutPriority(rawValue: 1000)

        NSLayoutConstraint.activate([
            textArea.topAnchor.constraint(equalTo: topAnchor),
            textArea.bottomAnchor.constraint(equalTo: bottomAnchor),
            textArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constraintLeftPadding),
            textArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constraintRightPadding),
            textAreaHeightConstraint,
        ])
        textArea.isScrollEnabled = false
    }
    
}


extension TextAreaContentView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        textArea.sizeToFit()
        guard let configuration = configuration as? TextAreaContentConfiguration else { return }
        configuration.delegate?.updateSize(animated: true)
        configuration.callbackOnChange?(configuration.moniker, textView.text)
    }
}


public struct TextAreaContentConfiguration: UIContentConfiguration {
    public func makeContentView() -> UIView & UIContentView {
        return TextAreaContentView(self)
    }
    
    public func updated(for state: UIConfigurationState) -> TextAreaContentConfiguration {
        return self
    }
    
    public var moniker: String?
    public var value: String?
    public var maximumTextLength: Int?
    public weak var delegate: TextAreaContentViewDelegate?
    
    public var callbackOnChange: ((String?, String?) -> Void)?
    
    init() {}
    
    public static func with(callback: (_ configuration: inout TextAreaContentConfiguration) -> Void) -> TextAreaContentConfiguration {
        var configuration = TextAreaContentConfiguration()
        callback(&configuration)
        return configuration
    }
    
    public func onChange(callback: @escaping (_ moniker: String?, _ value: String?) -> Void) -> TextAreaContentConfiguration {
        var configuration = self
        configuration.callbackOnChange = callback
        return configuration
    }
}



public protocol TextAreaContentViewDelegate: AnyObject {
    func updateDataSource(animated: Bool)
    func updateSize(animated: Bool)
}
