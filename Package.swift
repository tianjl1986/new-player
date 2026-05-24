// swift-tools-version: 5.8
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "TinPlayer",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .iOSApplication(
            name: "TinPlayer",
            targets: ["AppModule"],
            bundleIdentifier: "com.skeuo.tinplayer",
            displayVersion: "1.3.0",
            bundleVersion: "12",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait
            ],
            capabilities: [
                .mediaLibrary(purposeString: "我们需要访问您的本地音乐库以进行扫描和播放。"),
                .outgoingNetworkConnections()
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
