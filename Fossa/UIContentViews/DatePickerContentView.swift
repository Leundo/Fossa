//
//  DatePickerContentView.swift
//  Fossa
//
//  Created by Undo Hatsune on 2023/07/17.
//

import Foundation
import UIKit


class DatePickerContentView: UIView & UIContentView, UITextFieldDelegate {
    private let constraintHeight: CGFloat = Constant.standardHeight
    private let constraintLeftPadding: CGFloat = Constant.standardHorizonPadding
    private let constraintRightPadding: CGFloat = Constant.standardHorizonPadding
    private let constraintSpace: CGFloat = 8
    
    private let label = UILabel()
    private let textField = UITextField()
    private let datePicker = UIDatePicker()
    
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
        guard let configuration = configuration as? DatePickerContentConfiguration else { return }
        label.text = configuration.label
        textField.text = configuration.formatter.string(for: configuration.value)
        textField.placeholder = configuration.placeholder
        textField.textAlignment = .right
        datePicker.date = configuration.value ?? Date()
    }
    
    private func configureLayout() {
        textField.addTarget(self, action: #selector(textFieldDidChanged(_ :)), for: .editingChanged)
        datePicker.addTarget(self, action: #selector(datePickerDidChanged(_: )), for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        textField.clearButtonMode = .unlessEditing
        textField.returnKeyType = .done
        textField.delegate = self
        textField.inputView = datePicker
        textField.tintColor = .clear
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
    
    @objc private func datePickerDidChanged(_ sender: UIDatePicker) {
        guard let configuration = configuration as? DatePickerContentConfiguration else { return }
        textField.text = configuration.formatter.string(for: sender.date)
        configuration.callbackOnChange?(configuration.moniker, sender.date)
    }
    
    @objc private func textFieldDidChanged(_ sender: UITextField) {
        guard let configuration = configuration as? DatePickerContentConfiguration else { return }
        if sender.text == nil {
            configuration.callbackOnChange?(configuration.moniker, nil)
        }
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        return false
//    }
}


public struct DatePickerContentConfiguration: UIContentConfiguration {
    public func makeContentView() -> UIView & UIContentView {
        return DatePickerContentView(self)
    }
    
    public func updated(for state: UIConfigurationState) -> DatePickerContentConfiguration {
        return self
    }
    
    public var moniker: String?
    public var label: String?
    public var value: Date?
    public var placeholder: String?
    public var formatter: Formatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    public var callbackOnChange: ((String?, Date?) -> Void)?
    
    init() {}
    
    public static func with(callback: (_ configuration: inout DatePickerContentConfiguration) -> Void) -> DatePickerContentConfiguration {
        var configuration = DatePickerContentConfiguration()
        callback(&configuration)
        return configuration
    }
    
    public func onChange(callback: @escaping (_ moniker: String?, _ value: Date?) -> Void) -> DatePickerContentConfiguration {
        var configuration = self
        configuration.callbackOnChange = callback
        return configuration
    }
}
