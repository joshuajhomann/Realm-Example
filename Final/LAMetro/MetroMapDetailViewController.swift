//
//  MetroMapDetailViewController.swift
//  LAMetro
//
//  Created by Joshua Homann on 4/29/17.
//  Copyright © 2017 josh. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class MetroMapDetailViewController: UIViewController {
    // MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
    }
    @IBOutlet weak var mapView: MKMapView!
    // MARK: Variables
    var line: MetroLine!
    fileprivate var stops: Results<MetroStop>?
    private var notificationToken: NotificationToken?
    private var isLoading = false
    private var isMap = true
    private var addFavoriteButton: UIBarButtonItem!
    private var removeFavoriteButton: UIBarButtonItem!
    private var listButton: UIBarButtonItem!
    private var mapButton: UIBarButtonItem!
    // MARK: Constants
    fileprivate class Annotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var subtitle: String?
        init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
        }
    }
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Line \(line.lineNumber)"
        addFavoriteButton = UIBarButtonItem(image: #imageLiteral(resourceName: "button.empty.star"), style: .plain, target: self, action: #selector(toggleFavorite))
        removeFavoriteButton = UIBarButtonItem(image: #imageLiteral(resourceName: "button.filled.star") ,  style: .plain, target: self, action: #selector(toggleFavorite))
        listButton = UIBarButtonItem(image: #imageLiteral(resourceName: "button.list") ,  style: .plain, target: self, action: #selector(toggleMap))
        mapButton = UIBarButtonItem(image: #imageLiteral(resourceName: "button.map") ,  style: .plain, target: self, action: #selector(toggleMap))
        setupButtons()
        getData()
        subscribe()
    }

    deinit {
    }
    // MARK: Instance Methods
    private func getData() {
        guard isLoading == false else {
            return
        }
        isLoading = true
        line.getStops() { [weak self] result in
            guard let _self = self else {
                return
            }
            _self.isLoading = false
            switch result {
            case .success(let stops):
                break
            case .failure(let error):
                print(error)
            }
        }
    }

    private func subscribe() {
        notificationToken?.stop()
        notificationToken = line.stops.addNotificationBlock { [unowned self] (changes: RealmCollectionChange) in
            let coordinates = Array(self.line.stops.map {$0.coordinate})
            let poly = MKPolyline(coordinates: coordinates, count: coordinates.count)
            let annotations = Array(self.line.stops.map {Annotation(coordinate: $0.coordinate, title: $0.name, subtitle: nil)})
            self.mapView.add(poly)
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.showAnnotations(annotations, animated: true)
            self.tableView.reloadData()
        }
    }

    @objc private func refresh() {
        getData()
    }

    func setupButtons() {
        navigationItem.rightBarButtonItems = [ line.isFavorite ? removeFavoriteButton : addFavoriteButton, isMap ? listButton : mapButton]
    }
    @objc private func toggleFavorite() {
        line.isFavorite = !line.isFavorite
        setupButtons()
    }

    @objc private func toggleMap() {

        let sourceView = isMap ? mapView : tableView
        let destinationView = isMap ? tableView : mapView
        UIView.transition(from: sourceView, to: destinationView, duration: 0.5, options: [.showHideTransitionViews,isMap ? .transitionFlipFromRight : .transitionFlipFromLeft], completion: nil)
        isMap = !isMap
        setupButtons()
    }

    // MARK: IBAction
}

extension MetroMapDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 5
        renderer.strokeColor = UIColor.purple.withAlphaComponent(0.25)
        return renderer
    }

}

extension MetroMapDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MetroStopTableViewCell.reuseIdentifier) as! MetroStopTableViewCell
        cell.stop = stops![indexPath.row]
        return cell
    }
}
