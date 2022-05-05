//
//  SecureTokenStore.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import Foundation
import SwiftKeychainWrapper

public final class SecureTokenStore: TokenStore {
    
    private let key = "NimbleAuthToken"
    private let keychain: KeychainWrapper
    
    public init(keychain: KeychainWrapper = .standard) {
        self.keychain = keychain
    }
    
    public func load() -> AuthToken? {
        let data = keychain.data(forKey: key)
        guard let data = data else {
            return nil
        }
        return decode(data)
    }
    
    public func save(token: AuthToken) {
        guard let data = encode(token) else { return }
        keychain.set(data,
                                     forKey: key)
    }
    
    public func delete() {
        keychain.removeObject(forKey: key)
    }
    
    private func encode(_ token: AuthToken) -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(token)
    }
    
    private func decode(_ data: Data) -> AuthToken? {
        let decoder = JSONDecoder()
        return try? decoder.decode(AuthToken.self, from: data)
    }
    
}
