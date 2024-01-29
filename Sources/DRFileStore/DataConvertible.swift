//
//  DataConvertible.swift
//  DRFileStore
//
//  Created by Yannick Jacques on 2024-01-28.
//

import Foundation

public protocol DataConvertible {
    func toData() -> Data?
    static func fromData(_ data: Data) -> Self?
}
