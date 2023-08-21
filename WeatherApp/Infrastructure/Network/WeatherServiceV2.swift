//
//  WeatherServiceV2.swift
//  WeatherApp
//
//  Created by sandy on 2023/08/21.
//

import Foundation
import Alamofire
import Combine
import CoreLocation

protocol WeatherServiceV2Protocol {
    
}

class WeatherServiceV2 {
    private let baseUrl: String
    private let apiKey: String
    init(baseUrl: String, apiKey: String) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
    }
}


extension WeatherServiceV2: WeatherServiceV2Protocol {
    private func getData<T: Decodable>(_ url: String, paramters: Parameters? = nil) -> AnyPublisher<DataResponse<T, NetworkErrorV2>, Never> {
        let url = URL(string: self.baseUrl + url)!
        var params = paramters
        params?["key"] = self.apiKey
        return AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default)
            .validate()
            .validate(contentType: ["application/json"])
            .publishDecodable(type: T.self)
            .map { response in
                response.mapError { error in
                    let weatherError = response.data.flatMap { try? JSONDecoder().decode(WeatherErrorV2.self, from: $0)}
                    return NetworkErrorV2(initialError: error, weatherError: weatherError)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getForecastWeather(_ location: Location) -> AnyPublisher<DataResponse<CurrentResponseV2, NetworkErrorV2>, Never>{
        let params: [String: Any] = [
            "q": "\(location.lat),\(location.lon)",
            "lang": Utils.languageCode()
        ]as Parameters
        return self.getData("", paramters: params)
    }
    
    func getHistoryWeather(_ location: Location) -> AnyPublisher<DataResponse<CurrentResponseV2, NetworkErrorV2>, Never>{
        let params: [String: Any] = [
            "q": "\(location.lat),\(location.lon)",
            "lang": Utils.languageCode(),
            "dt": Utils.oneDayBefore()
        ]as Parameters
        return self.getData("", paramters: params)
    }
    
}
