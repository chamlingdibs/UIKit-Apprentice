//
//  AllListsViewController.swift
//  Checklist
//
//  Created by dibs on 04/03/23.
//

import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate {
    
    let cellIdentifier = "ChecklistCell"
    var dataModel : DataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        let index = dataModel.indexOfSelectedChecklist
        if index > 0 && index < dataModel.lists.count {
            let checklist = dataModel.lists[index]
            performSegue(withIdentifier: "ShowChecklist", sender: checklist )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataModel.lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell!
        if let tmp = tableView.dequeueReusableCell(withIdentifier: cellIdentifier){
            cell = tmp
        }else{cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        let checklist = dataModel.lists[indexPath.row]
        cell.textLabel!.text =  dataModel.lists[indexPath.row].name
        cell.accessoryType = .detailDisclosureButton
        let count = checklist.countUnCheckedItems()
        if checklist.items.count == 0{
            cell.detailTextLabel!.text = "(No Items)"
        }else{
            cell.detailTextLabel!.text = count == 0 ? "All Done" : "\(count) Remaining"
        }
        cell.imageView!.image = UIImage(named: checklist.iconName)
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataModel.indexOfSelectedChecklist = indexPath.row
        let checklist = dataModel.lists[indexPath.row]
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataModel.lists.remove(at: indexPath.row)
        let indexPath = [indexPath]
        tableView.deleteRows(at: indexPath, with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ListDetailViewController") as! ListDetailViewController
        controller.delegate = self
        let checklist = dataModel.lists[indexPath.row]
        controller.checklistToEdit = checklist
        navigationController?.pushViewController(controller, animated: true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! CheckListViewController
            controller.checklist = sender as? Checklist
        }else if segue.identifier == "AddChecklist"{
            let controller = segue.destination as! ListDetailViewController
            controller.delegate = self
        }
    }
    
    //MARK: - ListDetailViewController Delegates
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
        dataModel.lists.append(checklist)
        dataModel.sortChecklists()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
        dataModel.sortChecklists()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }

    //MARK: - Data saving
    
    func getDocumentDirectory() -> URL{
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return filePath[0]
    }
    
    func dataFilePath() -> URL{
        return getDocumentDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func saveChecklists(){
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(dataModel.lists)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        }catch{
            print( "Error Saving Data", error.localizedDescription)
        }
        print( dataFilePath() )
    }
    
    
    //MARK: - Navigation Controller Delegates
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Was the back button tapped?
        if viewController === self{
            dataModel.indexOfSelectedChecklist = -1
        }
    }
}
