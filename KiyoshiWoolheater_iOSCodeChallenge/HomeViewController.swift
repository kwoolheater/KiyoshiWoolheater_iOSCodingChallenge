//
//  HomeViewController.swift
//  KiyoshiWoolheater_iOSCodeChallenge
//
//  Created by Kiyoshi Woolheater on 3/23/18.
//  Copyright © 2018 Kiyoshi Woolheater. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var table: UITableView!
    private var mySearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        Client.sharedInstance().callAPI(searchText: nil) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }
        }
    }
    
    func setupUI() {
        // configure table view
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        table.backgroundView = UIImageView(image: UIImage(named: "cellBackground"))
        
        // make UISearchBar instance
        mySearchBar = UISearchBar(frame: CGRect.zero)
        mySearchBar.delegate = self
        
        // add searchBar to navigationBar
        self.navigationController?.navigationBar.addSubview(mySearchBar)
        
        // frame of the searchBar to navigationBar
        mySearchBar.sizeToFit()
        
        // set new frame with margins
        var frame = mySearchBar.frame
        frame.origin.x = 20
        frame.size.width -= 40
        mySearchBar.frame = frame
        mySearchBar.showsBookmarkButton = false
        mySearchBar.searchBarStyle = UISearchBarStyle.prominent
        mySearchBar.prompt = "Title"
        mySearchBar.placeholder = "Search Reddit"
        mySearchBar.showsSearchResultsButton = false
        
        // add searchBar to the view.
        self.navigationController?.navigationBar.addSubview(mySearchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        mySearchBar.text = ""
    }
    
    // called when search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        PostArray.sharedInstance().array.removeAll()
        Client.sharedInstance().callAPI(searchText: mySearchBar.text) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            } else {
                let alert = UIAlertController(title: "Bad Search Term", message: "No results for this term on reddit. Try again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        mySearchBar.text = ""
        self.mySearchBar.endEditing(true)
        self.view.endEditing(true)
    }
}

extension HomeViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostArray.sharedInstance().array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Load custom table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        // Populate the label and picture with artist name and image
        cell.username.text = PostArray.sharedInstance().array[indexPath.row].author
        cell.username.font = UIFont(name: "bebasneue", size: 20)
        cell.textView.text = PostArray.sharedInstance().array[indexPath.row].title
        cell.commentsLabel.text = "\(PostArray.sharedInstance().array[indexPath.row].num_comments!) comments"
        cell.upsLabel.text = "\(PostArray.sharedInstance().array[indexPath.row].ups!) ups"
        cell.downsLabel.text = "\(PostArray.sharedInstance().array[indexPath.row].downs!) downs"
        if PostArray.sharedInstance().array[indexPath.row].thumbnail != nil {
            cell.profilePic.image = UIImage(data: PostArray.sharedInstance().array[indexPath.row].thumbnail as! Data)
            cell.profilePic?.layer.cornerRadius = (cell.profilePic?.frame.size.width)! / 2
            cell.profilePic?.layer.masksToBounds = true
            cell.profilePic?.layer.borderColor = UIColor(red: 0, green: 182/255, blue: 255/255, alpha: 1).cgColor
            cell.profilePic?.layer.borderWidth = 5.0
        } else {
            cell.profilePic.image = UIImage(imageLiteralResourceName: "noImage")
            cell.profilePic?.layer.cornerRadius = (cell.profilePic?.frame.size.width)! / 2
            cell.profilePic?.layer.masksToBounds = true
            cell.profilePic?.layer.borderColor = UIColor(red: 0, green: 182/255, blue: 255/255, alpha: 1).cgColor
            cell.profilePic?.layer.borderWidth = 5.0
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sharable = ["Check out what\(PostArray.sharedInstance().array[indexPath.row].author!) just said on Reddit: '\(PostArray.sharedInstance().array[indexPath.row].title!).'"]
        let activityView = UIActivityViewController(activityItems: sharable, applicationActivities: nil)
        self.present(activityView ,animated: true, completion: nil)
        self.table.deselectRow(at: indexPath, animated: true)
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }*/
}
