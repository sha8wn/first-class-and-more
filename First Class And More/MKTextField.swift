//
//  MKTextField.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/15/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

@objc protocol MKTextFieldDelegate {
    @objc optional func mkTextFieldDidBeginEditing(_ mkTextField: MKTextField) -> Void
    @objc optional func mkTextFieldDidEndEditing(_ mkTextField: MKTextField) -> Void
    @objc optional func mkTextFieldShouldReturn(_ mkTextField: MKTextField) -> Void
}

class MKTextField: UIView, UITextFieldDelegate {
    // textField options
    override var tintColor: UIColor? {
        get { return textField.tintColor }
        set { textField.tintColor = newValue }
    }
    var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    var textColor: UIColor? {
        get { return textField.textColor }
        set { textField.textColor = newValue }
    }
    var placeholderColor: UIColor {
        get { return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) }
        set {
            let attributedPlaceholder = NSMutableAttributedString(
                string: placeholder ?? "",
                attributes: [
                    NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 14.0),
                    NSAttributedString.Key.foregroundColor: newValue
                ]
            )
            textField.attributedPlaceholder = attributedPlaceholder
        }
    }
    var font: UIFont? {
        get { return textField.font }
        set { textField.font = newValue }
    }
    var placeholder: String? {
        get { return textField.placeholder }
        set {
            if let string = newValue {
                let attributedPlaceholder = NSMutableAttributedString(
                    string: string,
                    attributes: [
                        NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 14.0),
                        NSAttributedString.Key.foregroundColor: placeholderColor
                    ]
                )
                textField.attributedPlaceholder = attributedPlaceholder
            }
        }
    }
    var attributedPlaceholder: NSAttributedString? {
        get { return textField.attributedPlaceholder }
        set { textField.attributedPlaceholder = newValue }
    }
    var capitalizationType: UITextAutocapitalizationType {
        get { return textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
    }
    var correctionType: UITextAutocorrectionType {
        get { return textField.autocorrectionType }
        set { textField.autocorrectionType = newValue }
    }
    var keyboardType: UIKeyboardType {
        get { return textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    var isSecureTextEntry: Bool {
        get { return textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    var returnKeyType: UIReturnKeyType {
        get { return textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    var mkDelegate: MKTextFieldDelegate?
    // textField
    private var textField: UITextField!
    // highlighter options
    var highlighterMargin: CGFloat = 4.0 {
        didSet {
            updateLayout()
        }
    }
    var highlighterHeight: CGFloat = 0.5 {
        didSet {
            updateLayout()
        }
    }
    var highlighterDefaultColor: UIColor {
        get { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5004676496) }
        set { highlighter.backgroundColor = textField.isEditing ? highlighterFocusedColor : newValue }
    }
    var highlighterFocusedColor: UIColor {
        get { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
        set { highlighter.backgroundColor = textField.isEditing ? newValue : highlighterDefaultColor }
    }
    // highlighter
    private var highlighter: UIView!
    // accesory button
    var accesoryBtnTitle: String? {
        get { return accesoryBtn.title(for: .normal) }
        set { accesoryBtn.setTitle(newValue, for: .normal) }
    }
    var accesoryBtnFont: UIFont? {
        get { return accesoryBtn.titleLabel?.font }
        set { accesoryBtn.titleLabel?.font = newValue }
    }
    var accesoryBtnTitleColor: UIColor? {
        get { return accesoryBtn.titleColor(for: .normal) }
        set { accesoryBtn.setTitleColor(newValue, for: .normal) }
    }
    var accesoryBtnRoundedCornerRadius: Bool {
        get { return false }
        set { accesoryBtn.layer.cornerRadius = newValue ? accesoryBtn.frame.size.height / 2 : 0 }
    }
    var accesoryBtnBorderWidth: CGFloat {
        get { return accesoryBtn.layer.borderWidth }
        set { accesoryBtn.layer.borderWidth = newValue }
    }
    var accesoryBtnBorderColor: UIColor? {
        get { if let cgColor = accesoryBtn.layer.borderColor { return UIColor(cgColor: cgColor) } else { return nil } }
        set { accesoryBtn.layer.borderColor = newValue?.cgColor }
    }
    var accesoryBtnTapped: (() -> Void)? = nil {
        didSet {
            accesoryBtn.isHidden = accesoryBtnTapped == nil
            var textFieldFrame = textField.frame
            textFieldFrame.size.width = accesoryBtnTapped == nil ?
                textFieldFrame.size.width : textFieldFrame.size.width - accesoryBtn.frame.size.width - 8.0
            textField.frame = textFieldFrame
        }
    }
    private var accesoryBtn: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI(withAccessoryButton: false)
    }
	
	init(withAccessoryButton: Bool = false) {
		super.init(frame: .zero)
		setupUI(withAccessoryButton: withAccessoryButton)
	}
    
    private func setupUI(withAccessoryButton: Bool) {
		addTextField(withAccessoryButton: withAccessoryButton)
		addHighlighter()
		if withAccessoryButton {
			addAccesoryBtn()
		}
    }
    
    private func addTextField(withAccessoryButton: Bool) {
		textField = UITextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = text
        textField.placeholder = placeholder
        textField.textColor = textColor
        textField.font = font
        textField.delegate = self
        addSubview(textField)
		
		NSLayoutConstraint.activate([
			textField.topAnchor.constraint(equalTo: topAnchor),
			textField.leadingAnchor.constraint(equalTo: leadingAnchor)
			])
		
		if !withAccessoryButton {
			NSLayoutConstraint.activate([
				textField.trailingAnchor.constraint(equalTo: trailingAnchor)
				])
		}
    }
    
    private func addHighlighter() {
		highlighter = UIView()
		highlighter.translatesAutoresizingMaskIntoConstraints = false
        highlighter.backgroundColor = highlighterDefaultColor
        addSubview(highlighter)
		
		NSLayoutConstraint.activate([
			highlighter.topAnchor.constraint(equalTo: textField.bottomAnchor),
			highlighter.leadingAnchor.constraint(equalTo: leadingAnchor),
			highlighter.trailingAnchor.constraint(equalTo: trailingAnchor),
			highlighter.heightAnchor.constraint(equalToConstant: highlighterHeight)
			])
    }
    
    private func addAccesoryBtn() {
        accesoryBtn = UIButton(type: .system)
		accesoryBtn.translatesAutoresizingMaskIntoConstraints = false
        accesoryBtn.setTitle(accesoryBtnTitle, for: .normal)
        accesoryBtn.setTitleColor(accesoryBtnTitleColor, for: .normal)
        accesoryBtn.layer.borderWidth = accesoryBtnBorderWidth
        accesoryBtn.layer.borderColor = accesoryBtnBorderColor?.cgColor
        accesoryBtn.clipsToBounds = true
        accesoryBtn.addTarget(self, action: #selector(accesoryBtnPressed), for: .touchUpInside)
        accesoryBtn.isHidden = true
        addSubview(accesoryBtn)
		
		NSLayoutConstraint.activate([
			accesoryBtn.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.08),
			accesoryBtn.heightAnchor.constraint(equalTo: accesoryBtn.widthAnchor),
			accesoryBtn.trailingAnchor.constraint(equalTo: trailingAnchor),
			accesoryBtn.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 4),
			accesoryBtn.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 4)
			])
    }
    
    @objc private func accesoryBtnPressed() {
        accesoryBtnTapped?()
    }
    
    private func updateLayout() {
        textField.frame = accesoryBtnTapped == nil ? CGRect(
            x: 0,
            y: 0,
            width: frame.size.width,
            height: frame.size.height - highlighterHeight - highlighterMargin
        ) : CGRect(
            x: 0,
            y: 0,
            width: frame.size.width - accesoryBtn.frame.size.width - 8.0,
            height: frame.size.height - highlighterHeight - highlighterMargin
        )
        highlighter.frame = CGRect(
            x: 0,
            y: frame.size.height - highlighterHeight - highlighterMargin,
            width: frame.size.width,
            height: highlighterHeight
        )
    }
    
    // MARK: UITextField Delegate
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        highlighter.backgroundColor = highlighterFocusedColor
        mkDelegate?.mkTextFieldDidBeginEditing?(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highlighter.backgroundColor = highlighterDefaultColor
        mkDelegate?.mkTextFieldDidBeginEditing?(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        mkDelegate?.mkTextFieldShouldReturn?(self)
        return true
    }
}
