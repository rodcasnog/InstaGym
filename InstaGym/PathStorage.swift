//
//  PathStorage.swift
//  InstaGym
//
//  Copyright © 2025 Rodrigo Casado. All rights reserved.
//  Licensed under the MIT License. See LICENSE for details.
//
import Foundation
import Observation
import SwiftUI

@Observable
class PathStorage {
//    private let storagePath = URL.documentsDirectory.appending(path: "navigationPathStoragePath")
    var path: NavigationPath
//    {
//        didSet {
//            save()
//        }
//    }
    
    init() {
//        if let data = try? Data(contentsOf: storagePath) {
//            if let decoded = try? JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: data) {
//                path = NavigationPath(decoded)
//                return
//            }
//        }
        path = NavigationPath()
    }
    
//    func save() {
//        do {
//            guard let codablePath = path.codable else { return }
//            let encoded = try JSONEncoder().encode(codablePath)
//            try encoded.write(to: storagePath)
//        } catch {
//            print("Error saving path: \(error)")
//        }
//    }
    
//    func clean() {
//        path = NavigationPath()
//    }
    
//    func printPath() {
//        let json = try! JSONEncoder().encode(path.codable!)
//        print(String(data: json, encoding: .utf8)!)
//    }
}
