//
//  AsteroidFieldView.swift
//  Asteroids
//
//  Created by Denver Stove on 2/11/18.
//  Copyright © 2018 Denver Stove. All rights reserved.
//

import UIKit

class AsteroidFieldView: UIView
{
//    var asteroidBehavior: AsteroidBehavior? {
//        didSet {
//            for asteroid in asteroids {
//                oldValue?.removeAsteroid(asteroid)
//                asteroidBehavior?.addAsteroid(asteroid)
//            }
//        }
//    }
//
//    private var asteroids: [AsteroidView] {
//        return subviews.flatMap { $0 as? AsteroidView }
//    }
    
    var scale: CGFloat = 0.002
    var minAsteroidSize: CGFloat = 0.25
    var maxAsteroidSize: CGFloat = 2.00
    
    func addAsteroids(count: Int, exclusionZone: CGRect = CGRect.zero) {
        assert(!bounds.isEmpty, "can't add asteroids to an empty field")
        let averageAsteroidSize = bounds.size * scale
        for _ in 0..<count {
            let asteroid = AsteroidView()
            asteroid.frame.size = (asteroid.frame.size / (asteroid.frame.size.area / averageAsteroidSize.area)) * CGFloat.random(in: minAsteroidSize..<maxAsteroidSize)
            repeat {
                asteroid.frame.origin = bounds.randomPoint
            } while !exclusionZone.isEmpty && asteroid.frame.intersects(exclusionZone)
            addSubview(asteroid)
            asteroidBehavior?.addAsteroid(asteroid)
        }
    }
}
