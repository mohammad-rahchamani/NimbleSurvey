//
//  SurveyLoader.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import Foundation

public class SurveyLoader {
    
    let loader: RequestLoader
    let baseURL: String
    
    public init(loader: RequestLoader, baseURL: String) {
        self.loader = loader
        self.baseURL = baseURL
    }
    
    public func load(page: Int,
                     size: Int,
                     tokenType: String,
                     accessToken: String,
                     completion: @escaping (Result<[Survey], Error>) -> ()) {
        
        loader.load(request: surveyListRequest(page: page,
                                               size: size,
                                               tokenType: tokenType,
                                               accessToken: accessToken)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(SurveyLoaderError.loaderError(error)))
            case .success(let data):
                completion(self.parseSurveyList(data))
            }
            
        }
        
    }
    
    public func getDetails(forSurvey id: String,
                           tokenType: String,
                           accessToken: String,
                           completion: @escaping (Result<[SurveyDetail], Error>) -> ()) {
        loader.load(request: surveyDetailRequest(id: id,
                                                 tokenType: tokenType,
                                                 accessToken: accessToken)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(SurveyLoaderError.loaderError(error)))
            case .success(let data):
                completion(self.parseSurveyDetails(data))
            }
        }
    }
    
    private func parseSurveyList(_ data: Data) -> Result<[Survey], Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let object = try decoder.decode(SurveyResponse.self, from: data)
            return .success(object.data)
        } catch {
            print(error)
            return .failure(SurveyLoaderError.invalidData)
        }
    }
    
    private func parseSurveyDetails(_ data: Data) -> Result<[SurveyDetail], Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let object = try decoder.decode(SurveyDetailResponse.self, from: data)
            return .success(object.included)
        } catch {
            print(error)
            return .failure(SurveyLoaderError.invalidData)
        }
    }
    
    private func surveyListRequest(page: Int,
                                   size: Int,
                                   tokenType: String,
                                   accessToken: String) -> URLRequest {
        var components = URLComponents(string: "\(baseURL)/api/v1/surveys")!
        components.queryItems = [
            URLQueryItem(name: "page[number]", value: "\(page)"),
            URLQueryItem(name: "page[size]", value: "\(size)")
        ]
        let url = components.url!
        var request = URLRequest(url: url)
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Authorization"] = "\(tokenType) \(accessToken)"
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        return request
    }
    
    private func surveyDetailRequest(id: String,
                                     tokenType: String,
                                     accessToken: String) -> URLRequest {
        let url = URL(string: "\(baseURL)/api/v1/surveys/\(id)")!
        var request = URLRequest(url: url)
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Authorization"] = "\(tokenType) \(accessToken)"
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        return request
     }
    
    enum SurveyLoaderError: Error {
        case loaderError(Error)
        case invalidData
    }
    
    struct ResponseMetadata: Codable {
        let page: Int
        let pages: Int
        let pageSize: Int
        let records: Int
    }
    
    private struct SurveyResponse: Codable {
        let data: [Survey]
        let meta: ResponseMetadata
    }
    
    private struct SurveyDetailResponse: Codable {
        let data: Survey
        let included: [SurveyDetail]
    }
    
}
