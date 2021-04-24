//
//  View+.swift
//  CityBike
//
//  Created by Sergio Rodríguez Rama on 24/4/21.
//

import Foundation
import SwiftUI

extension View {
    var notPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"
    }
}
