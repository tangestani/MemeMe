//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Mohammed Tangestani on 8/22/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SentMemesTableViewController: UITableViewController {
    
    var memes: [Meme] {
        get {
            (UIApplication.shared.delegate as! AppDelegate).memes
        }
        set {
            (UIApplication.shared.delegate as! AppDelegate).memes = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.title = "Sent Memes"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    @objc
    func addTapped() {
        let memeEditorVC = UINavigationController(rootViewController: MemeEditorViewController())
        memeEditorVC.modalPresentationStyle = .fullScreen
        present(memeEditorVC, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let meme = memes[indexPath.item]

        // Configure the cell...
        cell.contentView.backgroundColor = .secondarySystemBackground
//        cell.imageView?.contentMode = .center
        cell.imageView?.image = meme.memedImage
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.lineBreakMode = .byTruncatingMiddle
        cell.textLabel?.text = [meme.topText, meme.bottomText]
            .compactMap { $0 }
            .joined(separator: " ")
            .uppercased()
        
//        imageView.contentMode = .scaleAspectFill
//        cell.contentView.addSubview(imageView)
//        imageView.frame = cell.contentView.bounds
//        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meme = memes[indexPath.item]
        let memeDetailVC = MemeDetailViewController(meme: meme)
        navigationController?.pushViewController(memeDetailVC, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
