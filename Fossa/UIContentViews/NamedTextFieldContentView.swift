//
//  NamedTextFieldContentView.swift
//  Fossa
//
//  Created by Undo Hatsune on 2023/07/17.
//

import Foundation
import UIKit


public class NamedTextFieldContentView<Value: NamedTextFieldContentValue>: UIView & UIContentView, UITextFieldDelegate {
    private let constraintHeight: CGFloat = Constant.standardHeight
    private let constraintLeftPadding: CGFloat = Constant.standardHorizonPadding
    private let constraintRightPadding: CGFloat = Constant.standardHorizonPadding
    private let constraintSpace: CGFloat = 8
    
    private let label = UILabel()
    private let textField = UITextField()
    
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
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: constraintHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? NamedTextFieldContentConfiguration<Value> else { return }
        label.text = configuration.label
        textField.text = configuration.value?.toStringAtFossa()
        textField.placeholder = configuration.placeholder
        textField.textAlignment = .right
        textField.keyboardType = configuration.keyboardType ?? Value.usedKeyboardTypeAtFossa
    }
    
    private func configureLayout() {
        textField.addTarget(self, action: #selector(textFieldDidChanged(_ :)), for: .editingChanged)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.doneAccessory = true
        textField.textColor = .secondaryLabel
        textField.autocorrectionType = .no
        textField.delegate = self
        
        addSubview(textField)
        addSubview(label)
        textField.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // setContentHuggingPriority
        // adjustsFontSizeToFitWidth
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
      
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constraintLeftPadding),
            label.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -constraintSpace),
            
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constraintRightPadding),
        ])
    }
    
    @objc private func textFieldDidChanged(_ sender: UITextField) {
        guard let configuration = configuration as? NamedTextFieldContentConfiguration<Value> else { return }
        configuration.callbackOnChange?(configuration.moniker, Value.fromAtFossa(sender.text))
    }

    // MARK: - TextField
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        guard let configuration = configuration as? TextFieldContentConfiguration, let maximumTextLength = configuration.maximumTextLength else { return true }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= maximumTextLength
    }
}


public struct NamedTextFieldContentConfiguration<Value: NamedTextFieldContentValue>: UIContentConfiguration {
    public func makeContentView() -> UIView & UIContentView {
        return NamedTextFieldContentView<Value>(self)
    }
    
    public func updated(for state: UIConfigurationState) -> NamedTextFieldContentConfiguration {
        return self
    }
    
    public var moniker: String?
    public var label: String?
    public var value: Value?
    public var placeholder: String?
    public var maximumTextLength: Int?
    public var keyboardType: UIKeyboardType?
    
    public var callbackOnChange: ((String?, Value?) -> Void)?
    
    init() {}
    
    public static func with(callback: (_ configuration: inout NamedTextFieldContentConfiguration) -> Void) -> NamedTextFieldContentConfiguration {
        var configuration = NamedTextFieldContentConfiguration()
        callback(&configuration)
        return configuration
    }
    
    public func onChange(callback: @escaping (_ moniker: String?, _ value: Value?) -> Void) -> NamedTextFieldContentConfiguration {
        var configuration = self
        configuration.callbackOnChange = callback
        return configuration
    }
}


public protocol NamedTextFieldContentValue {
    static var usedKeyboardTypeAtFossa: UIKeyboardType { get }
    static func fromAtFossa(_ string: String?) -> Self?
    func toStringAtFossa() -> String
}


extension String: NamedTextFieldContentValue {
    public static let usedKeyboardTypeAtFossa: UIKeyboardType = .default
    
    public static func fromAtFossa(_ string: String?) -> String? {
        return string
    }
    
    public func toStringAtFossa() -> String {
        return self
    }
}


extension Int: NamedTextFieldContentValue {
    public static let usedKeyboardTypeAtFossa: UIKeyboardType = .numberPad
    
    public static func fromAtFossa(_ string: String?) -> Int? {
        guard let string = string else { return nil }
        return Int(string)
    }
    
    public func toStringAtFossa() -> String {
        return String(self)
    }
}


extension Double: NamedTextFieldContentValue {
    public static let usedKeyboardTypeAtFossa: UIKeyboardType = .decimalPad
    
    public static func fromAtFossa(_ string: String?) -> Double? {
        guard let string = string else { return nil }
        return Double(string)
    }
    
    public func toStringAtFossa() -> String {
        return String(self)
    }
}
