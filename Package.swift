// swift-tools-version:5.0

//
//  Package.swift
//  Xpandr
//
//  Created by Denis Avdeev on 18.04.2020.
//  Copyright © 2020-2025 Denis Avdeev. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "DAExpandAnimation",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(name: "DAExpandAnimation", targets: ["DAExpandAnimation"])
    ],
    targets: [
        .target(name: "DAExpandAnimation")
    ]
)
