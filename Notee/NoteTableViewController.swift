//
//  NoteTableViewController.swift
//  Notee
//
//  Created by Francis Adewale on 23/10/2020.
//

import UIKit
import CoreData
import Speech

class NoteTableViewController: SwipeCellViewController, SFSpeechRecognizerDelegate
{
    //MARK: - Properties
    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-UK"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = selectedCategory?.name
        speechRecognizer.delegate = self

    
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.text
        cell.accessoryType = .detailButton

        return cell
    }
    
    //MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Date Posted", message: "\(itemArray[indexPath.row].date!)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Dismiss", style: .cancel) { (alertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)

    }
    
   
    //MARK: - IB Actions
    @IBAction func addNotePressed(_ sender: UIBarButtonItem) {
        
        
        var textfield = UITextField()
        
        let actionSheet = UIAlertController(title: "Select Option", message: "", preferredStyle: .actionSheet)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            
        }
        
        let noteAction = UIAlertAction(title: "Write Note", style: .default) { (alertAction) in
            
            let alert = UIAlertController(title: "Write a note", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
                let newItem = Item(context: self.context)
                newItem.text = textfield.text!
                newItem.parentCategory = self.selectedCategory
                newItem.date = Date()

                self.itemArray.append(newItem)
                self.saveItem()
            }
            
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Create Category"
                textfield = alertTextField
            }
            
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        let recordAction = UIAlertAction(title: "Record Note", style: .default) { (recordAction) in
            recordAction.isEnabled
        }
        
        actionSheet.addAction(noteAction)
        actionSheet.addAction(cancelButton)
        actionSheet.addAction(recordAction)
        
        present(actionSheet, animated: true, completion: nil)
       
    }
    
    //MARK: - Data Manipulation
    
    override func updateModel(at indexPath: IndexPath) {
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
        
    }
    
    
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Could not save \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems() {
        let predicate = NSPredicate(format:"parentCategory.name MATCHES %@", selectedCategory!.name!)
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            itemArray = try context.fetch(fetchRequest)
        } catch {
            print("Can't fetch results \(error)")
        }
    }
    
}
