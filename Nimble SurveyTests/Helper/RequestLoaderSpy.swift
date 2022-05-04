//
//  RequestLoaderSpy.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import Foundation
import Nimble_Survey

class RequestLoaderSpy: RequestLoader {
    
    private(set) var messages: [URLRequest : (Result<Data, Error>) -> ()] = [:]
    
    func load(request: URLRequest,
              completion: @escaping (Result<Data, Error>) -> ()) {
        messages[request] = completion
    }
    
    func completeLoad(for request: URLRequest, with result: Result<Data, Error>) {
        messages[request]?(result)
    }
    
    func completeLoad(at index: Int = 0, with result: Result<Data, Error>) {
        Array(messages.values)[index](result)
    }
    
    
}
