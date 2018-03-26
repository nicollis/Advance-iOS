//
//  ExpenseDetailViewController.swift
//  Expense Sieve
//
//  Created by Michael Ward on 7/18/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ExpenseDetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var vendorField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var commentField: UITextField!
    @IBOutlet var dateButton: UIButton!

    @IBOutlet var receiptTapLabel: UILabel!
    @IBOutlet var receiptImageView: UIImageView!
    @IBOutlet var mainStackView: UIStackView!
    
    var imageCache: ImageCache!
    var currentExpense: Expense!
    
    var amountFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    var onDismiss: (()->Void)? {
        willSet {
            assert(onDismiss == nil, "onDismiss is already set!")
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vendorField.text = currentExpense.vendor
        commentField.text = currentExpense.comment
        amountField.text = amountFormatter.string(from: NSNumber(value: currentExpense.amount))
        
        updateDateButton(currentExpense.date)
        
        if let image = imageCache?.image(forKey: currentExpense.photoKey) {
            updateReceiptImageView(image)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed || isMovingFromParentViewController {
            vendorField.endEditing(true)
            commentField.endEditing(true)
            amountField.endEditing(true)
            onDismiss?()
        }
    }
    
    func updateDateButton(_ date: Date) {
        dateButton.setTitle(dateFormatter.string(from: date), for: .normal)
    }
    
    func updateReceiptImageView(_ image: UIImage?) {
        receiptImageView.image = image
        receiptTapLabel.isHidden = !(image == nil)
    }
    
    // MARK: - Transitioning
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dateVC = segue.destination as? DatePickerViewController else { return }
        
        dateVC.onDismiss = {
            let date = dateVC.datePicker.date
            if self.currentExpense.date != date {
                self.currentExpense.date = date
                self.updateDateButton(date)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleReceiptTap(_ sender: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Text Field Delegate
    
    func validatedAmount() -> Double? {
        let amountText = amountField.text ?? ""
        return Double(amountText) ?? amountFormatter.number(from: amountText) as? Double
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case vendorField:
            currentExpense.vendor = vendorField.text ?? NSLocalizedString("Unknown Vendor", comment: "")
        case commentField:
            currentExpense.comment = commentField.text
        case amountField:
            if let amount = validatedAmount() {
                amountField.backgroundColor = nil
                amountField.text = amountFormatter.string(from: NSNumber(value: amount))
                currentExpense.amount = amount
            } else {
                amountField.backgroundColor = UIColor.red
            }

        default:
            assertionFailure("Unrecognized text field finished editing!")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case vendorField:
            commentField.becomeFirstResponder()
        case commentField:
            amountField.becomeFirstResponder()
        case amountField:
            if validatedAmount() == nil {
                amountField.resignFirstResponder()
            } else {
                vendorField.becomeFirstResponder()
            }
        default:
            assertionFailure("Unrecognized text field returned!")
        }
        return true
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }

        imageCache?.set(image, forKey: currentExpense.photoKey)
        updateReceiptImageView(image)
        
        dismiss(animated: true, completion: nil)
    }
}
