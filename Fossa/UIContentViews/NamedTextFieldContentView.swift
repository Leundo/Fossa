//
//  NamedTextFieldContentView.swift
//  Fossa
//
//  Created by Undo Hatsune on 2023/07/17.
//

import Foundation
import UIKit


class NamedTextFieldContentView: UIView & UIContentView {
    public static let constraintHeight: CGFloat = Constant.standardHeight
    public static let constraintLeftPadding: CGFloat = Constant.standardHorizonPadding
    public static let constraintRightPadding: CGFloat = Constant.standardHorizonPadding
    public static let constraintSpace: CGFloat = 8
    
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
        CGSize(width: 0, height: Self.constraintHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? NamedTextFieldContentConfiguration else { return }
        label.text = configuration.label
        textField.text = configuration.value
        textField.placeholder = configuration.placeholder
        textField.textAlignment = .right
    }
    
    private func configureLayout() {
        textField.addTarget(self, action: #selector(textFieldDidChanged(_ :)), for: .editingChanged)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.doneAccessory = true
        
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
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.constraintLeftPadding),
            label.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -Self.constraintSpace),
            
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.constraintRightPadding),
        ])
    }
    
    @objc private func textFieldDidChanged(_ sender: UITextField) {
        guard let configuration = configuration as? TextFieldContentConfiguration else { return }
        configuration.callbackOnChange?(configuration.moniker, sender.text)
    }
}


extension NamedTextFieldContentView: UITextFieldDelegate {
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


public struct NamedTextFieldContentConfiguration: UIContentConfiguration {
    public func makeContentView() -> UIView & UIContentView {
        return NamedTextFieldContentView(self)
    }
    
    public func updated(for state: UIConfigurationState) -> NamedTextFieldContentConfiguration {
        return self
    }
    
    public var moniker: String?
    public var label: String?
    public var value: String?
    public var placeholder: String?
    public var maximumTextLength: Int?
    
    public var callbackOnChange: ((String?, String?) -> Void)?
    
    init() {}
    
    public static func with(callback: (_ configuration: inout NamedTextFieldContentConfiguration) -> Void) -> NamedTextFieldContentConfiguration {
        var configuration = NamedTextFieldContentConfiguration()
        callback(&configuration)
        return configuration
    }
    
    public func onChange(callback: @escaping (_ moniker: String?, _ value: String?) -> Void) -> NamedTextFieldContentConfiguration {
        var configuration = self
        configuration.callbackOnChange = callback
        return configuration
    }
}
