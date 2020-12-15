//
//  fullVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 15/12/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import UIKit

class fullVC: UIViewController, UITextViewDelegate {
    
    var day = Day()
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var backgroundV: UIView!
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = day.toString
        self.navigationItem.largeTitleDisplayMode = .never
        textView.text = titles[day,true] ?? ""
        backgroundV.backgroundColor = AppTintColor.value.withAlphaComponent(0.1)
        updateText()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        textView.scrollIndicatorInsets = textView.contentInset

        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    func textViewDidChange(_ textView: UITextView){
        titles[day,true] = textView.text
        updateText()
    }
    
    func updateText(){
        let old = textView.text ?? ""
        let str = NSMutableAttributedString(string: old)
        let splited = old.split(separator: "\n")
        str.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20), range: NSRange(location: 0, length: str.length ))
        str.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 30), range: NSRange(location: 0, length: splited.count < 1 ? 0 : splited[0].count ))
        let temp = textView.selectedRange
        textView.attributedText = str
        textView.selectedRange = temp
        textView.textColor = UIColor.label
    }
    


}
