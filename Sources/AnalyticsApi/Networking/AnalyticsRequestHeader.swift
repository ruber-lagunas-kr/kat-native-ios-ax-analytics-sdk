//
//  AnalyticsRequestHeader.swift
//
//
//  Created by Jason Dees on 10/27/20.
//

import Foundation

public protocol AnalyticsRequestHeader {
    var key: String { get }
    var value: String { get }
}
