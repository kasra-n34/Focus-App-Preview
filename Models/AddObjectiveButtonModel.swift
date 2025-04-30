//
//  AddObjectiveButtonModel.swift
//  Focus
//
//  Created by Kasra on 2024-08-22.
//

import Foundation
import SwiftUI

struct AddObjectiveButtonModel {
    var title: String
    var imageName: String
    var category: String
    var units: String
    var API: String
    var segmentedItems: [String]? = nil // Optional segmented items
    var explanations: [String]?
}
