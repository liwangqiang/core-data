//
//  MoodDetailViewController.swift
//  Moody
//
//  Created by Daniel Eggert on 15/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import MapKit


class MoodDetailViewController: UIViewController {
    @IBOutlet weak var moodView: MoodView!
    // 可以直接在 SB 中拖拽 MKMapView
    @IBOutlet weak var mapView: MKMapView!

    fileprivate var observer: ManagedObjectObserver?

    var mood: Mood! {
        didSet {
            observer = ManagedObjectObserver(object: mood) { [unowned self] type in
                guard type == .delete else { return }
                let _ = self.navigationController?.popViewController(animated: true)
            }
            updateViews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

    @IBAction func deleteMood(_ sender: UIBarButtonItem) {
        mood.managedObjectContext?.performChanges {
            self.mood.managedObjectContext?.delete(self.mood)
        }
    }


    // MARK: Private

    fileprivate func updateViews() {
        moodView?.colors = mood.colors
        mapView?.alpha = 1
        navigationItem.title = mood.dateDescription
        updateMapView()
    }

    fileprivate func updateMapView() {
        guard let map = mapView, let annotation = MoodAnnotation(mood: mood) else { return }
        map.removeAnnotations(mapView!.annotations)
        map.addAnnotation(annotation)
        map.selectAnnotation(annotation, animated: false)
        map.setCenter(annotation.coordinate, animated: false)
        map.setRegion(MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 2e6, longitudinalMeters: 2e6), animated: false)
    }
}


private let dateComponentsFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    formatter.includesApproximationPhrase = true
    formatter.allowedUnits = [.minute, .hour, .weekday, .month, .year]
    formatter.maximumUnitCount = 1
    return formatter
}()


extension Mood {
    var dateDescription: String {
        guard let timeString = dateComponentsFormatter.string(from: abs(date.timeIntervalSinceNow)) else { return "" }
        return localized(.mood_dateComponentFormat, args: [timeString])
    }
}


class MoodAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?

    fileprivate init?(mood: Mood) {
        coordinate = mood.location?.coordinate ?? CLLocationCoordinate2D()
        title = mood.country.localizedDescription
        super.init()
        guard let _ = mood.location, let _ = title else { return nil }
    }
}


