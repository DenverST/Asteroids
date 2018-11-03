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
        behaviour.collisionMode = .everything
        behaviour.translatesReferenceBoundsIntoBoundary = true
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
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(physics)
    }
    
    func addAsteroid(_ asteroid: AsteroidView) {
        asteroids.append(asteroid)
        collider.addItem(asteroid)
        physics.addItem(asteroid)
    }
    
    func removeAsteroid(_ asteroid: AsteroidView) {
        if let index = asteroids.index(of: asteroid) {
            asteroids.remove(at: index)
        }
        collider.removeItem(asteroid)
        physics.removeItem(asteroid)
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
}
