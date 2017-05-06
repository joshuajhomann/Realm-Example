//
//   MARK: IBAction MetroStopTableViewCell.swift
//  LAMetro
//
//  Created by Joshua Homann on 5/5/17.
//  Copyright © 2017 josh. All rights reserved.
//

import UIKit

class MetroStopTableViewCell: UITableViewCell {
    // MARK: IBOutlet
    @IBOutlet weak var descriptionLabel: UILabel!
    // MARK: Variables
    var stop: MetroStop! {
        didSet {
            setup()
        }
    }
    // MARK: Constants
    static let reuseIdentifier = String(describing: MetroStopTableViewCell.self)
    // MARK: UITableViewCell
    // MARK: Instance Methods
    private func setup() {
        descriptionLabel.text = stop.name
    }
    // MARK: IBAction
}
