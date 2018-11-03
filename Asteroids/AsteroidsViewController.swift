//
//  ViewController.swift
//  Asteroids
//
//  Created by Denver Stove on 2/11/18.
//  Copyright © 2018 Denver Stove. All rights reserved.
//

import UIKit

class AsteroidsViewController: UIViewController
{
    
    private var asteroidField: AsteroidFieldView!
    private var ship: SpaceshipView!
    
    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.asteroidField)
    
    private var asteroidBehaviour = AsteroidBehaviour()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeIfNeeded()
        animator.addBehavior(asteroidBehaviour)
        asteroidBehaviour.pushAllAsteroids()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animator.removeBehavior(asteroidBehaviour)
    }
    
    private func initializeIfNeeded() {
        if asteroidField == nil {
            asteroidField = AsteroidFieldView(frame: CGRect(center: self.view.bounds.mid, size: view.bounds.size))
            view.addSubview(asteroidField)
            let shipSize = view.bounds.size.minEdge * Constants.shipSizeToMinBoundsEdgeRatio
            ship = SpaceshipView(frame: CGRect(squareCenteredAt: asteroidField.center, size: shipSize))
            view.addSubview(ship)
            repostionShip()
            asteroidField.asteroidBehaviour = asteroidBehaviour
            asteroidField.addAsteroids(count: Constants.initialAsteroidCount, exclusionZone: ship.convert(ship.bounds, to: asteroidField))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        asteroidField?.center = view.bounds.mid
        repostionShip()
    }
    
    private func repostionShip() {
        if asteroidField != nil {
            ship.center = asteroidField.center
            asteroidBehaviour.setBounday(ship.shieldBoundary(in: asteroidField), named: Constants.shipBoundaryName) { [weak self] in
                if let ship = self?.ship {
                    if !ship.shieldIsActive {
                        ship.shieldIsActive = true
                        ship.shieldLevel -= Constants.Shield.activationCost
                        Timer.scheduledTimer(withTimeInterval: Constants.Shield.duration, repeats: false) { timer in
                            ship.shieldIsActive = false
                            if ship.shieldLevel == 0 {
                                ship.shieldLevel = 100
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private struct Constants {
        static let initialAsteroidCount = 20
        static let shipBoundaryName = "Ship"
        static let shipSizeToMinBoundsEdgeRatio: CGFloat = 1/5
        static let asteroidFieldMagnitude: CGFloat = 10
        static let normalizedDistanceOfShipFromEdge: CGFloat = 0.2
        static let burnAcceleration: CGFloat = 0.07
        struct Shield {
            static let duration: TimeInterval = 1.0
            static let updateInterval: TimeInterval = 0.2
            static let regenerationRate: Double = 5
            static let activationCost: Double = 15
            static var regenerationPerUpdate: Double
            { return Constants.Shield.regenerationRate * Constants.Shield.updateInterval }
            static var activationCostPerUpdate: Double
            { return Constants.Shield.activationCost / (Constants.Shield.duration/Constants.Shield.updateInterval) }
        }
        static let defaultShipDirection: [UIInterfaceOrientation:CGFloat] = [
            .portrait : CGFloat.up,
            .portraitUpsideDown : CGFloat.down,
            .landscapeLeft : CGFloat.right,
            .landscapeRight : CGFloat.left
        ]
        static let normalizedAsteroidFieldCenter: [UIInterfaceOrientation:CGPoint] = [
            .portrait : CGPoint(x: 0.5, y: 1.0-Constants.normalizedDistanceOfShipFromEdge),
            .portraitUpsideDown : CGPoint(x: 0.5, y: Constants.normalizedDistanceOfShipFromEdge),
            .landscapeLeft : CGPoint(x: Constants.normalizedDistanceOfShipFromEdge, y: 0.5),
            .landscapeRight : CGPoint(x: 1.0-Constants.normalizedDistanceOfShipFromEdge, y: 0.5),
            .unknown : CGPoint(x: 0.5, y: 0.5)
        ]
    }
}
