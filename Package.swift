// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "Tunnel",
                      platforms: [.iOS(.v8)],
                      products: [.library(name: "Tunnel",
                                          targets: ["Tunnel"])],
                      targets: [.target(name: "Tunnel",
                                        path: "Sources"),
                                .testTarget(
                                    name: "TunnelTests",
                                    dependencies: ["Tunnel"]),],
                      swiftLanguageVersions: [.v5])
