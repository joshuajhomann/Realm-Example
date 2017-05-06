//
//  MetroLineListViewController.swift
//  LAMetro
//
//  Created by Joshua Homann on 4/29/17.
//  Copyright © 2017 josh. All rights reserved.
//

import UIKit
import RealmSwift

class MetroLineListViewController: UIViewController {
    // MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
    }
    // MARK: Variables
    fileprivate var lines: Results<MetroLine>?
    private var notificationToken: NotificationToken?
    private var isLoading = false
    // MARK: Constants
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        getData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? MetroMapDetailViewController,
            let index = tableView.indexPathForSelectedRow?.row {
            destination.line = lines![index]
        }
    }



    deinit {
        notificationToken?.stop()
    }
    // MARK: Instance Methods
    private func getData() {
        guard isLoading == false else {
            return
        }
        isLoading = true
        MetroLine.getAll() { [weak self] result in
            guard let _self = self else {
                return
            }
            _self.isLoading = false
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print(error)
                }
                _self.tableView.refreshControl?.endRefreshing()
            }
        }
    }

    private func subscribe() {
        guard let realm = try? Realm() else {
            return
        }
        notificationToken?.stop()
        lines = realm.objects(MetroLine.self).sorted(byKeyPath: "name", ascending: true)
        notificationToken = lines?.addNotificationBlock { [unowned self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                self.tableView.endUpdates()
            case .error(let error):
                print(error.localizedDescription)
            }
        }
    }

    @objc private func refresh() {
        getData()
    }
    // MARK: IBAction
}

extension MetroLineListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MetroLineTableViewCell.reuseIdentifier) as! MetroLineTableViewCell
        cell.line = lines![indexPath.row]
        return cell
    }
}

