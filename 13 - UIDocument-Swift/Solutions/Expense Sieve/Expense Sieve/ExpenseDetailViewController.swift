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
    
    @IBOutlet var undoButton: UIBarButtonItem!
    @IBOutlet var redoButton: UIBarButtonItem!

    @IBOutlet var receiptTapLabel: UILabel!
    @IBOutlet var receiptImageView: UIImageView!
    @IBOutlet var mainStackView: UIStackView!
    
    var doc: Document!
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
        updateUndoRedoButtons()
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
        doc.undoManager?.removeAllActions()
        updateUndoRedoButtons()
    }
    
    func updateDateButton(_ date: Date) {
        dateButton.setTitle(dateFormatter.string(from: date), for: .normal)
    }
    
    func updateReceiptImageView(_ image: UIImage?) {
        receiptImageView.image = image
        receiptTapLabel.isHidden = !(image == nil)
    }
    
    func updateUndoRedoButtons() {
        undoButton.isEnabled = doc.undoManager.canUndo
        redoButton.isEnabled = doc.undoManager.canRedo
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
    
    @IBAction func handleUndoButtonTap(_ sender: UIBarButtonItem) {
        doc.undoManager.undo()
        updateUndoRedoButtons()
    }
    
    @IBAction func handleRedoButtonTap(_ sender: UIBarButtonItem) {
        doc.undoManager.redo()
        updateUndoRedoButtons()
    }
    
    // MARK: - Text Field Delegate
    
    func validatedAmount() -> Double? {
        let amountText = amountField.text ?? ""
        return Double(amountText) ?? amountFormatter.number(from: amountText) as? Double
    }
    
    func updateVendor(_ newVendor: String?) {
        let oldVendor = currentExpense.vendor
        
        currentExpense.vendor = newVendor ?? NSLocalizedString("Unknown Vendor", comment: "")
        vendorField.text = newVendor

        doc.undoManager.registerUndo(withTarget: self) { (thisVC) in
            thisVC.updateVendor(oldVendor)
        }
        
        updateUndoRedoButtons()
    }
    
    func updateComment(_ newComment: String?) {
        let oldComment = currentExpense.comment
        
        currentExpense.comment = newComment
        commentField.text = newComment
        
        doc.undoManager.registerUndo(withTarget: self) { (thisVC) in
            thisVC.updateComment(oldComment)
        }
        
        updateUndoRedoButtons()
    }

    func updateAmount(_ newAmount: Double) {
        let oldAmount = currentExpense.amount
        
        amountField.backgroundColor = nil
        amountField.text = amountFormatter.string(from: NSNumber(value: newAmount))
        currentExpense.amount = newAmount
        
        doc.undoManager.registerUndo(withTarget: self) { (thisVC) in
            thisVC.updateAmount(oldAmount)
        }
        
        updateUndoRedoButtons()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case vendorField:
            updateVendor(vendorField.text)
        case commentField:
            updateComment(commentField.text)
        case amountField:
            if let amount = validatedAmount() {
                updateAmount(amount)
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
    
    func updateImage(_ newImage: UIImage?) {
        let oldImage = receiptImageView.image
        
        imageCache?.set(newImage, forKey: currentExpense.photoKey)
        updateReceiptImageView(newImage)
        
        doc.undoManager.registerUndo(withTarget: self) { (thisVC) in
            self.updateImage(oldImage)
        }
        
        updateUndoRedoButtons()
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        updateImage(image)
        
        dismiss(animated: true, completion: nil)
    }
}



