//
//  MailHelper.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 13/02/23.
//

import Foundation
import MessageUI

class MailHelper: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = MailHelper()
    
    func sendEmail(subject: String, body: String, to: String, completion: @escaping (Bool) -> Void){
        if MFMailComposeViewController.canSendMail(){
            let picker = MFMailComposeViewController()
            picker.setSubject(subject)
            picker.setMessageBody(body, isHTML: false)
            picker.setToRecipients([to])
            picker.mailComposeDelegate = self
            
            UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true, completion: nil)
        }
        
        completion(MFMailComposeViewController.canSendMail())
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
