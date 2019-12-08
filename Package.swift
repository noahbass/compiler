// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "compilerproject",
    products: [
        .executable(name: "compilerprojectexecutable", targets: ["compilerprojectexecutable"]),
        .library(name: "compilerproject", targets: ["compilerproject"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "compilerprojectexecutable",
            dependencies: ["compilerproject"],
            path: "./src/compiler-project-executable/"
        ),
        .target(
            name: "compilerproject",
            dependencies: [],
            path: "./src/compiler-project-lib/"
        ),
        .testTarget(
            name: "compilerprojectTests",
            dependencies: ["compilerproject"],
            path: "./test/"
        ),
    ]
)
