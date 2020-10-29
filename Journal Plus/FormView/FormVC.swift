//
//  ViewController.swift
//  FormView
//
//  Created by Jacob Hanna on 29/09/2020.
//

import UIKit
import SwiftUI

protocol Presenting {
    func reload()
}

extension UIViewController{
    
    func showForm(_ getter : @escaping (()->FormProperties)){
        
        
        let vc = Bundle.main.loadNibNamed("FormVC", owner: nil, options: nil)?.first as! FormVC
        
        vc.caller = self
        vc.propGetter = getter
        
        vc.setProps(getter())
        
        vc.view.tintColor = self.view.tintColor
        
        vc.providesPresentationContextTransitionStyle = true
        vc.modalPresentationStyle = .formSheet
        vc.modalTransitionStyle = .coverVertical

        self.definesPresentationContext = false
        
        self.present(vc, animated: true, completion: nil)
    }
}

class FormVC: UIViewController, Presenting {
    
    func reload() {
        updateProps(propGetter())
    }
    

    @IBOutlet weak var mainView: UIView!
    
    static var top : FormVC? = nil
    
    var prev : FormVC? = nil
    
    var propGetter : (()->FormProperties) = {
        return FormProperties(title: "Prop Getter Err")
    }
    var caller : UIViewController!
    var callerPresentable : Presenting?{
        return caller as? Presenting
    }
    var content : UIHostingController<FormView>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prev = FormVC.top
        FormVC.top = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        callerPresentable?.reload()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        FormVC.top = prev
    }
    
    func updateProps(_ fp : FormProperties){
        content.rootView.props = fp
    }
    
    func setProps (_ fp : FormProperties){
        
        content = UIHostingController(rootView: FormView(props: fp, dismiss: {
            self.dismiss(animated: true, completion: nil)
        }))
        
        
        content.view.backgroundColor = UIColor.clear
        addChild(content)
        content.view.frame = mainView.frame
        mainView.addSubview(content.view)
        content.didMove(toParent: self)
        
        setUp()
    }
    
    func setUp(){
        content.view.translatesAutoresizingMaskIntoConstraints = false
        content.view.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        content.view.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        content.view.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
        content.view.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
    }
}

