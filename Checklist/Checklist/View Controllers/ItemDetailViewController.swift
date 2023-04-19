//
//  AddItemViewController.swift
//  Checklist
//
//  Created by dibs on 02/03/23.
//

import UIKit
protocol ItemDetailViewControllerDelegate : AnyObject{
    func ItemDetailViewControllerDidCancel( _ controller : ItemDetailViewController)
    func ItemDetailViewController( _ controller : ItemDetailViewController, didFinishAdding item : CheckListItem)
    func ItemDetailViewController( _ controller : ItemDetailViewController, didFinishEditing item: CheckListItem)
}
class ItemDetailViewController: UITableViewController, UITextFieldDelegate{

    
    // IBOutlet
    @IBOutlet var doneBarButton: UIBarButtonItem!
    @IBOutlet var textField: UITextField!
    @IBOutlet weak var shouldRemindSwitch : UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //Properties
    weak var delegate : ItemDetailViewControllerDelegate?
    
    var itemToEdit : CheckListItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
        navigationItem.largeTitleDisplayMode = .never
        
        if let itemToEdit = itemToEdit{
            navigationItem.title = "Edit"
            textField.text = itemToEdit.text
            doneBarButton.isEnabled = true
            shouldRemindSwitch.isOn = itemToEdit.shouldRemind
            datePicker.date = itemToEdit.dueDate
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? 1 : 2
    }


    //MARK: - TableView Delegates
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    //MARK: - Actions
    
    @IBAction func shouldRemindToggled( _ switchControl : UISwitch){
        if switchControl.isOn{
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]){ _,_ in
                    //do nothing
            }
        }
    }
    
    @IBAction func cancel(){
        delegate?.ItemDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done(){
        if let item = itemToEdit{
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = datePicker.date
            item.scheduleNotification()
            delegate?.ItemDetailViewController(self, didFinishEditing: item)
        }else{
            let item = CheckListItem()
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = datePicker.date
            item.scheduleNotification()
            delegate?.ItemDetailViewController(self, didFinishAdding: item)
        }
        
    }
    
    //MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }

}
