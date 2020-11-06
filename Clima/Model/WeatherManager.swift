//
//  Weather.swift
//  Clima
//
//  Created by Илья Дернов on 03.11.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WetherManagerDelegate {
    func didUpdateWeather(weather: WeatherModule)
    func didFailedWithError(error: Error)
}

struct WeatherManager {
    let apiUrl:String = "https://api.openweathermap.org/data/2.5/weather?appid=46c2c9a861a950ed7a504a7eaa7d104f&units=metric"
    
    var delegate: WetherManagerDelegate?
    
    func getWeather(cityName: String) {
        let url = "\(apiUrl)&q=\(cityName)"
        request(url: url)
    }
    
    func getWeather(latitude: Double, longitude: Double) {
        let url = "\(apiUrl)&lat=\(latitude)&lon=\(longitude)"
        request(url: url)
    }
    
    func request(url: String) {
        if let urlRequest = URL(string: url) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: urlRequest) {(data, responce, error) in
                if error != nil {
                    self.delegate?.didFailedWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weatherModule = parceJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(weather: weatherModule)
                    }
                }
            }
            task.resume()
            
        }
    }
    
    func parceJSON(weatherData: Data) -> WeatherModule? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let cityName = decodedData.name
            let temperature = decodedData.main.temp
            let weatherModule = WeatherModule(condId: id, cityName: cityName, temperature: temperature)
            return weatherModule
        } catch {
            delegate?.didFailedWithError(error: error)
            return nil
        }
        
    }
    

    
}
