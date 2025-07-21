// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // 👇 это делает PieChart доступным для импорта как `import PieChart`
        .library(name: "PieChart", targets: ["PieChart"]),
    ],
    targets: [
        // 👇 сам таргет PieChart
        .target(
            name: "PieChart",
            dependencies: []
        ),
        .testTarget(
            name: "PieChartTests",
            dependencies: ["PieChart"]
        ),
    ]
)
