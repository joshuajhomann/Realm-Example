//
//  MetroLineListViewController.swift
//  LAMetro
//
//  Created by Joshua Homann on 4/29/17.
//  Copyright © 2017 josh. All rights reserved.
//

import UIKit

class MetroLineListViewController: UIViewController {
    // MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
    }
    // MARK: Variables
    fileprivate var lines: [MetroLine] = []
    private var isLoading = false
    // MARK: Constants
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? MetroMapDetailViewController,
            let index = tableView.indexPathForSelectedRow?.row {
            destination.line = lines[index]
        }
    }



    deinit {
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
                case .success(let lines):
                    _self.lines.removeAll()
                    _self.lines.append(contentsOf: lines)
                    _self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
                _self.tableView.refreshControl?.endRefreshing()
            }
        }
    }

    @objc private func refresh() {
        getData()
    }
    // MARK: IBAction
    @IBAction func unwind(segue: UIStoryboardSegue) {
        if segue.source is MetroMapDetailViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension MetroLineListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MetroLineTableViewCell.reuseIdentifier) as! MetroLineTableViewCell
        cell.delegate = self
        cell.line = lines[indexPath.row]
        return cell
    }
}

extension MetroLineListViewController: MetroLineTableViewCellDelegate {
    func update(cell: MetroLineTableViewCell, isFavorite: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        lines[indexPath.row].isFavorite = isFavorite
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
