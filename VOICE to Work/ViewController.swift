
import UIKit
import CoreData


class ViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var label: UILabel!
    
    var models: [(title: String, note: String)] = []

//    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        title = "Notes"
        
        

//        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
//
//        do {
//            let people = try PersistanceService.context.fetch(fetchRequest)
//            self.people = people
//            self.table.reloadData()
//        } catch {}


        

    }
    
    
    
    
    @IBAction func didTapNewNote() {
        guard let vc = storyboard?.instantiateViewController(identifier: "new") as? EntryViewController else {
            return
        }
        vc.title = "New Note"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { noteTitle, note in
            self.navigationController?.popToRootViewController(animated: true)
            
            let name = noteTitle
            let age = note
            let person = Person(context: PersistanceService.context)

            person.note = age
            person.title = name
            
            PersistanceService.saveContext()
//            self.people.append((title: noteTitle, note: note))
            self.table.reloadData()
            
            self.models.append((title: noteTitle, note: note))
            self.label.isHidden = true
            self.table.isHidden = false
            PersistanceService.saveContext()
            self.table.reloadData()
//
            
            
            
        }
        navigationController?.pushViewController(vc, animated: true)
        
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.models.remove(at: indexPath.row)
//            self.people.remove(at: indexPath.row)
            self.table.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        action.image = #imageLiteral(resourceName: "delete")
        action.backgroundColor = .systemRed
        
        return action
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = shareAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [complete])
    }
    
    
    
    func shareAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            
            completion(true)
        }
        action.image = #imageLiteral(resourceName: "share")
        action.backgroundColor = .systemBlue
        
        
        
        let activityVC = UIActivityViewController(activityItems: [""], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        
        return action
    }
    
    
    
    
    
    
    // Table
    
    
    
}


extension ViewController: UITableViewDataSource, NSFetchedResultsControllerDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        cell.detailTextLabel?.text = models[indexPath.row].note
//        cell.textLabel?.text = people[indexPath.row].title
//        cell.detailTextLabel?.text = people[indexPath.row].note
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = models[indexPath.row]
        
//        let ppl = people[indexPath.row]
        
        // Show note controller
        guard let vc = storyboard?.instantiateViewController(identifier: "note") as? NoteViewController else {
            return
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = "Note"
        vc.noteTitle = model.title
        vc.note = model.note
        
//        vc.noteTitle = ppl.title!
//        vc.note = ppl.note!
//
        navigationController?.pushViewController(vc, animated: true)
//        print(models[indexPath.row])
////         print(people[indexPath.row])
    }
    
    
}

