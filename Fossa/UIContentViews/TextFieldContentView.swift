//
//  TextFieldContentView.swift
//  Fossa
//
//  Created by Undo Hatsune on 2023/07/17.
//

import Foundation
import UIKit


public class TextFieldContentView: UIView & UIContentView {
    private let constraintHeight: CGFloat = Constant.standardHeight
    
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
        guard let configuration = configuration as? TextFieldContentConfiguration else { return }
        textField.text = configuration.value
        textField.placeholder = configuration.placeholder
    }
    
    private func configureLayout() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChanged(_ :)), for: .editingChanged)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.doneAccessory = true

        addPinnedSubview(textField, insets: UIEdgeInsets(top: 0, left: Constant.standardHorizonPadding, bottom: 0, right: Constant.standardHorizonPadding))
    }
    
    @objc private func textFieldDidChanged(_ sender: UITextField) {
        guard let configuration = configuration as? TextFieldContentConfiguration else { return }
        configuration.callbackOnChange?(configuration.moniker, sender.text)
    }
}


extension TextFieldContentView: UITextFieldDelegate {
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


public struct TextFieldContentConfiguration: UIContentConfiguration {
    public func makeContentView() -> UIView & UIContentView {
        return TextFieldContentView(self)
    }
    
    public func updated(for state: UIConfigurationState) -> TextFieldContentConfiguration {
        return self
    }
    
    public weak var delegate: TextFieldContentViewDelegate?
    public var moniker: String?
    public var value: String?
    public var placeholder: String?
    public var maximumTextLength: Int?
    
    public var callbackOnChange: ((String?, String?) -> Void)?
    
    init() {}
    
    public static func with(callback: (_ configuration: inout TextFieldContentConfiguration) -> Void) -> TextFieldContentConfiguration {
        var configuration = TextFieldContentConfiguration()
        callback(&configuration)
        return configuration
    }
    
    public func onChange(callback: @escaping (_ moniker: String?, _ value: String?) -> Void) -> TextFieldContentConfiguration {
        var configuration = self
        configuration.callbackOnChange = callback
        return configuration
    }
}


public protocol TextFieldContentViewDelegate: AnyObject {}
