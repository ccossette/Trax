//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Carlo Cossette on 2015-06-17.
//  Copyright (c) 2015 C Cossette. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController
{
    var waypointToEdit: EditableWaypoint? {didSet {updateUI()}}


    @IBOutlet weak var nameTextField: UITextField! { didSet { infoTextField.delegate = self }}
    @IBOutlet weak var infoTextField: UITextField! { didSet { nameTextField.delegate = self }}

    func updateUI()
    {
        nameTextField.text = waypointToEdit?.name
        infoTextField.text = waypointToEdit?.info
    }
    
    @IBAction func done(sender: UIBarButtonItem)
    {
        presentingViewController?.dismissViewControllerAnimated(true, completion: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeTextFields()
    }
    
    var ntfObserver: NSObjectProtocol?
    var itfObserver: NSObjectProtocol?
    
    func observeTextFields()
    {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        ntfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: nameTextField, queue: queue) { notification  in
            if let waypoint = self.waypointToEdit
            {
                waypoint.name = self.nameTextField.text
            }
        }
        
        itfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: infoTextField, queue: queue) { notification  in
            if let waypoint = self.waypointToEdit
            {
                waypoint.info = self.infoTextField.text
            }
        }

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = ntfObserver
        {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let observer = itfObserver
        {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
        updateUI()

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }

}
