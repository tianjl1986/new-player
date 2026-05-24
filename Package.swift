// swift-tools-version: 5.8
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "NewPlayer",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .iOSApplication(
            name: "NewPlayer",
            targets: ["AppModule"],
            bundleIdentifier: "com.skeuo.newplayer",
            displayVersion: "1.0.0",
            bundleVersion: "1",
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait
            ],
            capabilities: [
                .mediaLibrary(purposeString: "需要访问您的本地音乐库以进行音频扫描和播放。")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources"
        )
    ]
)
