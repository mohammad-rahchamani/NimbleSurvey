//
//  NetworkHandler.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/3/22.
//

import Foundation

public final class NetworkHandler {
    
    private static let VALID_STATUS_CODES = 200...299
    
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func load(request: URLRequest,
                     completion: @escaping (Result<Data, Error>) -> ()) {
        session.dataTask(with: request) { [weak self] data, response, error in
            
            guard let _ = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  NetworkHandler.isResponseValid(response),
                  !data.isEmpty else {
                      completion(.failure(NetworkHandlerError.invalidData))
                      return
            }
            
            completion(.success(data))
            
        }.resume()
    }
    
    private static func isResponseValid(_ response: URLResponse?) -> Bool {
        guard let response = response as? HTTPURLResponse else {
            return false
        }
        return VALID_STATUS_CODES.contains(response.statusCode)
    }
    
    private enum NetworkHandlerError: Error {
        case invalidData
    }
    
}
