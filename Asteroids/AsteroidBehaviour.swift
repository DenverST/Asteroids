//
//  AsteroidBehaviour.swift
//  Asteroids
//
//  Created by Denver Stove on 2/11/18.
//  Copyright © 2018 Denver Stove. All rights reserved.
//

import UIKit

class AsteroidBehaviour: UIDynamicBehavior, UICollisionBehaviorDelegate
{
    
    private lazy var collider: UICollisionBehavior = {
        let behaviour = UICollisionBehavior()
        behaviour.collisionMode = .boundaries
//        behaviour.translatesReferenceBoundsIntoBoundary = true
        behaviour.collisionDelegate = self
        return behaviour
    }()
    
    private lazy var physics: UIDynamicItemBehavior = {
        let behaviour = UIDynamicItemBehavior()
        behaviour.elasticity = 1
        behaviour.allowsRotation = true
        behaviour.friction = 0
        behaviour.resistance = 0
        return behaviour
    }()
    
    lazy var acceleration: UIGravityBehavior = {
        let behaviour = UIGravityBehavior()
        behaviour.magnitude = 0
        
        return behaviour
    }()
    
    
    
    // functions are just types, no different to a string, can be put in a dictionary
    private var collisionHandlers = [String:()->(Void)]()
    
    func setBounday(_ path: UIBezierPath?, named name: String, handler: (()->Void)?) {
        collisionHandlers[name] = nil
        collider.removeBoundary(withIdentifier: name as NSString)
        if path != nil {
            collider.addBoundary(withIdentifier: name as NSString, for: path!)
            collisionHandlers[name] = handler
        }
    }
    
    func collisionBehavior(
        _ behavior: UICollisionBehavior,
        beganContactFor item: UIDynamicItem,
        withBoundaryIdentifier identifier: NSCopying?,
        at p: CGPoint) {
        if let name = identifier as? String, let handler = collisionHandlers[name] {
            handler()
        }
    }
    
    var speedLimit: CGFloat = 300.0
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(physics)
        addChildBehavior(acceleration)
        physics.action = { [weak self] in
            for asteroid in self?.asteroids ?? [] {
                let velocity = self!.physics.linearVelocity(for: asteroid)
                let excessHorizontalVelocity = min(self!.speedLimit - velocity.x, 0)
                let excessVerticalVelocity = min(self!.speedLimit - velocity.y, 0)
                self!.physics.addLinearVelocity(CGPoint(x: excessHorizontalVelocity, y: excessVerticalVelocity), for: asteroid)
            }
        }
    }
    
    func addAsteroid(_ asteroid: AsteroidView) {
        asteroids.append(asteroid)
        collider.addItem(asteroid)
        physics.addItem(asteroid)
        acceleration.addItem(asteroid)
        startRecapturingWaywardAsteroids()
    }
    
    func removeAsteroid(_ asteroid: AsteroidView) {
        if let index = asteroids.index(of: asteroid) {
            asteroids.remove(at: index)
        }
        collider.removeItem(asteroid)
        physics.removeItem(asteroid)
        acceleration.removeItem(asteroid)
        if asteroids.isEmpty {
            stopRecapturingWaywardAsteroids()
        }
    }
    
    override func willMove(to dynamicAnimator: UIDynamicAnimator?) {
        super.willMove(to: dynamicAnimator)
        if dynamicAnimator == nil {
            stopRecapturingWaywardAsteroids()
        } else if !asteroids.isEmpty {
            startRecapturingWaywardAsteroids()
        }
    }
    
    
    
    func pushAllAsteroids(by magnitude: Range<CGFloat> = 0..<1.0) {
        for asteroid in asteroids {
            let pusher = UIPushBehavior(items: [asteroid], mode: .instantaneous)
            pusher.magnitude = CGFloat.random(in: magnitude)
            pusher.angle = CGFloat.random(in: 0..<CGFloat.pi*2)
            addChildBehavior(pusher)
        }
    }

    private var asteroids = [AsteroidView]()
    
    var recaptureCount = 0
    private weak var recaptureTimer: Timer?
    
    private func startRecapturingWaywardAsteroids() {
        if recaptureTimer == nil {
            recaptureTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                for asteroid in self?.asteroids ?? [] {
                    if let asteroidFieldBounds = asteroid.superview?.bounds, !asteroidFieldBounds.contains(asteroid.center) {
                        asteroid.center.x = asteroid.center.x.truncatingRemainder(dividingBy: asteroidFieldBounds.width)
                        if asteroid.center.x < 0 { asteroid.center.x += asteroidFieldBounds.width }
                        asteroid.center.y = asteroid.center.y.truncatingRemainder(dividingBy: asteroidFieldBounds.height)
                        if asteroid.center.y < 0 { asteroid.center.y += asteroidFieldBounds.height }
                        self?.dynamicAnimator?.updateItem(usingCurrentState: asteroid)
                        self?.recaptureCount += 1
                    }
                }
            }
        }
    }
    
    private func stopRecapturingWaywardAsteroids() {
        recaptureTimer?.invalidate()
    }
}
