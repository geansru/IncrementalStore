/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

class BugSquasherViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  var bugs: [Bug] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Bug Squasher"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }

  // In this method we load the saved data from previous app launches
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    guard let appDelegate = UIApplication.shared.delegate as? BugSquasherAppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bug")

    do {
      bugs =
        try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Bug]
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }

  // This method adds a random number of terrible bugs to our never-ending bugs list
  @IBAction func refreshList(_ sender: UIBarButtonItem) {

    let numOfNewBugs = Int(arc4random_uniform(6) + 1)

    for _ in 0...numOfNewBugs {
      self.save(title: "Worst bug ever!")
    }

    self.tableView.reloadData()
  }

  // Here we can add specific bugs with custom text, one at a time
  @IBAction func addNewBug(_ sender: UIBarButtonItem) {

    let alert = UIAlertController(title: "Terrible Bug!!!",
                                  message: "Name your terrible top priority bug",
                                  preferredStyle: .alert)

    let saveAction = UIAlertAction(title: "File Bug!", style: .default) {
      [unowned self] action in

      guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
        return
      }

      self.save(title: nameToSave)
      self.tableView.reloadData()
    }

    let cancelAction = UIAlertAction(title: "Never Mind", style: .default)

    alert.addTextField()

    alert.addAction(saveAction)
    alert.addAction(cancelAction)

    present(alert, animated: true)
  }

  // This method saves new bugs for future app launches
  func save(title: String) {

    guard let appDelegate = UIApplication.shared.delegate as? BugSquasherAppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Bug", in: managedContext)!

    let bug = NSManagedObject(entity: entity, insertInto: managedContext)
    bug.setValue(title, forKeyPath: "title")
    bug.setValue(bugs.count+1, forKeyPath: "bugID")

    do {
      try managedContext.save()
      bugs.append(bug as! Bug)
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
}

// MARK: - UITableViewDataSource
extension BugSquasherViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return bugs.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let bug = bugs[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = bug.value(forKeyPath: "title") as? String
    return cell
  }
}

// MARK: - UITableViewDelegate
extension BugSquasherViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // Deselct the row so it won't remain highlighted
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
