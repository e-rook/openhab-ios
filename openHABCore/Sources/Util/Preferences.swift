// Copyright (c) 2010-2020 Contributors to the openHAB project
//
// See the NOTICE file(s) distributed with this work for additional
// information.
//
// This program and the accompanying materials are made available under the
// terms of the Eclipse Public License 2.0 which is available at
// http://www.eclipse.org/legal/epl-2.0
//
// SPDX-License-Identifier: EPL-2.0

import os.log
import UIKit

// Convenient access to UserDefaults

// Much shorter as Property Wrappers are available with Swift 5.1
// Inspired by https://www.avanderlee.com/swift/property-wrappers/
@propertyWrapper
public struct UserDefault<T> {
    let key: String
    let defaultValue: T

    public var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

// It would be nice to write something like  @UserDefault @TrimmedURL ("localUrl", defaultValue: "test") static var localUrl: String
// As long as multiple property wrappers are not supported we need to add a little repetitive boiler plate code

@propertyWrapper
public struct UserDefaultURL {
    let key: String
    let defaultValue: String

    public var wrappedValue: String {
        get {
            guard let localUrl = UserDefaults.standard.string(forKey: key) else { return defaultValue }
            let trimmedUri = uriWithoutTrailingSlashes(localUrl).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if !validateUrl(trimmedUri) { return defaultValue }
            return trimmedUri
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    init(_ key: String, defaultValue: String) {
        self.key = key
        self.defaultValue = defaultValue
    }

    private func validateUrl(_ stringURL: String) -> Bool {
        // return nil if the URL has not a valid format
        let url: URL? = URL(string: stringURL)
        return url != nil
    }

    func uriWithoutTrailingSlashes(_ hostUri: String) -> String {
        if !hostUri.hasSuffix("/") {
            return hostUri
        }

        return String(hostUri[..<hostUri.index(before: hostUri.endIndex)])
    }
}

public struct Preferences {
    private static let defaults = UserDefaults.standard

    @UserDefaultURL("localUrl", defaultValue: "") public static var localUrl: String
    @UserDefaultURL("remoteUrl", defaultValue: "https://openhab.org:8444") public static var remoteUrl: String

    @UserDefault("username", defaultValue: "test") public static var username: String
    @UserDefault("password", defaultValue: "test") public static var password: String
    @UserDefault("alwaysSendCreds", defaultValue: false) public static var alwaysSendCreds: Bool
    @UserDefault("ignoreSSL", defaultValue: false) public static var ignoreSSL: Bool
    // @UserDefault("sitemapName", defaultValue: "watch") static public var sitemapName: String
    @UserDefault("demomode", defaultValue: true) public static var demomode: Bool
    @UserDefault("idleOff", defaultValue: false) public static var idleOff: Bool
    @UserDefault("realTimeSliders", defaultValue: false) public static var realTimeSliders: Bool
    @UserDefault("iconType", defaultValue: 0) public static var iconType: Int
    @UserDefault("defaultSitemap", defaultValue: "demo") public static var defaultSitemap: String
    @UserDefault("sendCrashReports", defaultValue: false) public static var sendCrashReports: Bool
}
