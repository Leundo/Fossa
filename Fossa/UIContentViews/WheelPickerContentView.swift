//
//  WheelPickerContentView.swift
//  Fossa
//
//  Created by Undo Hatsune on 2023/07/17.
//

import Foundation
import UIKit


class WheelPickerContentView<Value: WheelPickerContentValue>: UIView & UIContentView, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let constraintHeight: CGFloat = Constant.standardHeight
    private let constraintLeftPadding: CGFloat = Constant.standardHorizonPadding
    private let constraintRightPadding: CGFloat = Constant.standardHorizonPadding
    private let constraintSpace: CGFloat = 8
    
    private let label = UILabel()
    private let textField = UITextField()
    private let picker = UIPickerView()
    
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
        guard let configuration = configuration as? WheelPickerContentConfiguration<Value> else { return }
        label.text = configuration.label
        textField.text = configuration.value.description
        textField.placeholder = configuration.placeholder
        textField.textAlignment = .right
        picker.selectRow(Value.caseCollection.firstIndex(of: configuration.value) ?? 0, inComponent: 0, animated: false)
    }
    
    private func configureLayout() {
        picker.delegate = self
        picker.dataSource = self
        textField.returnKeyType = .done
        textField.delegate = self
        textField.inputView = picker
        textField.tintColor = .clear
        textField.textColor = .secondaryLabel
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
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constraintLeftPadding),
            label.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -constraintSpace),
            
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constraintRightPadding),
        ])
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Value.caseCollection.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Value.caseCollection[row].description
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let value = Value.caseCollection[row]
        textField.text = value.description
        guard let configuration = configuration as? WheelPickerContentConfiguration<Value> else { return }
        configuration.callbackOnChange?(configuration.moniker, value)
    }
}


public struct WheelPickerContentConfiguration<Value: WheelPickerContentValue>: UIContentConfiguration {
    public func makeContentView() -> UIView & UIContentView {
        return WheelPickerContentView<Value>(self)
    }
    
    public func updated(for state: UIConfigurationState) -> WheelPickerContentConfiguration {
        return self
    }
    
    public var moniker: String?
    public var label: String?
    public var value: Value = Value.defaultValue
    public var placeholder: String?
    
    public var callbackOnChange: ((String?, Value?) -> Void)?
    
    init() {}
    
    public static func with(callback: (_ configuration: inout WheelPickerContentConfiguration) -> Void) -> WheelPickerContentConfiguration {
        var configuration = WheelPickerContentConfiguration()
        callback(&configuration)
        return configuration
    }
    
    public func onChange(callback: @escaping (_ moniker: String?, _ value: Value?) -> Void) -> WheelPickerContentConfiguration {
        var configuration = self
        configuration.callbackOnChange = callback
        return configuration
    }
}


public protocol WheelPickerContentValue: Equatable {
    static var defaultValue: Self { get }
    static var caseCollection: [Self] { get }
    var description: String { get }
}
