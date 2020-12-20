//
//  ShareViewController.swift
//  JournalShareExtension
//
//  Created by Jacob Hanna on 21/12/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import UIKit
import Social
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    var props : FormProperties?{
        didSet{
            setProps()
        }
    }
    @IBOutlet weak var mainView: UIView!
    var content : UIHostingController<FormView>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = AppTintColor.value
        Titles.reload()
        getPropsFromFile()
        
    }
    
    func setUp(){
        content.view.translatesAutoresizingMaskIntoConstraints = false
        content.view.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        content.view.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        content.view.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
        content.view.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
    }
    
    func setProps (){
        
        content = UIHostingController(rootView: FormView(props: props ?? FormProperties(title: "Error"), dismiss: {
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        }))
        
        
        content.view.backgroundColor = UIColor.clear
        addChild(content)
        content.view.frame = mainView.frame
        mainView.addSubview(content.view)
        content.didMove(toParent: self)
        
        setUp()
    }

    func getPropsFromFile(){
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType =  UTType.fileURL.identifier
          for provider in attachments {
            // Check if the content type is the same as we expected
            if provider.hasItemConformingToTypeIdentifier(contentType) {
              provider.loadItem(forTypeIdentifier: contentType,
                                options: nil) { [unowned self] (data, error) in
              // Handle the error here if you want
              guard error == nil else { return }
                
                if let url = data as? URL{
                    
                    do{
                        let json = try String(contentsOf: url, encoding: String.Encoding.utf8)
                        DispatchQueue.main.async {
                           props = GetSetTitles.formViewFromFileString(str: json)
                        }
                        
                    }catch{
                        
                    }
                    
                    
                    
                    
              } else {
                // Handle this situation as you prefer
                fatalError("Impossible to save image")
              }
            }}
          }
    }

}
