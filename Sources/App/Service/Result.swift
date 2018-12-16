//
//  Result.swift
//  WeatherApp
//
//  Created by xxx on 11/2/18.
//  Copyright © 2018 Belkhadir. All rights reserved.
//

import Foundation

enum Result<T, U: Error> {
    case success(T)
    case failure(U)
}
