//
//  ViewController.swift
//  Checklist
//
//  Created by dibs on 26/02/23.
//

import UIKit

class CheckListViewController: UITableViewController, ItemDetailViewControllerDelegate {
    
    
    var items = [CheckListItem]()
    var checklist : Checklist!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        loadChecklistItems()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = checklist.name
    }

    //MARK: - TableView Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checklistCell", for: indexPath)
        let item = checklist.items[indexPath.row]
        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)
        return cell
    }
    
    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            let item = checklist.items[indexPath.row]
            item.checked.toggle()
            configureCheckmark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        saveChecklistItems()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        checklist.items.remove(at: indexPath.row)
        let indexPath = [indexPath]
        tableView.deleteRows(at: indexPath, with: .fade)
    }
    
    //MARK: - Helper Methods
    func configureCheckmark( for cell : UITableViewCell,
                             with item : CheckListItem){
        let label = cell.viewWithTag(1001) as! UILabel
        if item.checked{
            label.text = "√"
        }else{
            label.text = ""
        }
    }
    
    
    func configureText( for cell : UITableViewCell, with item: CheckListItem){
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = "\(item.text)"
    }
    
    //MARK: - Actions
    @IBAction func addItem(){
        let newRow = checklist.items.count
        let item = CheckListItem()
        item.text = "New item"
        item.checked = true
        items.append(item)
        let indexPath = IndexPath(row: newRow, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem"{
            let controller = segue.destination as! ItemDetailViewController
            controller.delegate = self
        }else if segue.identifier == "EditItem"{
            let controller = segue.destination as! ItemDetailViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        }
    }

    func getDocumentDirectory() -> URL{
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return url[0]
    }
    
    func getDataFilePath() -> URL{
        return getDocumentDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func loadChecklistItems(){
        let path = getDataFilePath()
        if let data = try? Data(contentsOf: path){
            let decoder = PropertyListDecoder()
            do{
                items = try decoder.decode([CheckListItem].self, from: data)
            }catch{
                print( "Error:\(error.localizedDescription)")
            }
        }
    }
    
    func saveChecklistItems(){
        let encoder = PropertyListEncoder()
        let path = getDataFilePath()
        do{
            let data = try encoder.encode(items)
            try data.write(to: path, options: Data.WritingOptions.atomic)
        }catch{
            print( "Error : \(error.localizedDescription)")
        }
    }
    
    //MARK: - Add Item ViewController Delegates
    
    func ItemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func ItemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: CheckListItem) {
        let newRowIndex = checklist.items.count
        checklist.items.append(item)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        navigationController?.popViewController(animated: true)
        saveChecklistItems()
    }
    
    func ItemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: CheckListItem) {
        if let index = checklist.items.firstIndex(where: { $0 === item }){
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath){
                configureText(for: cell, with: item)
            }
        }
        navigationController?.popViewController(animated: true)
        saveChecklistItems()
    }
    
}



