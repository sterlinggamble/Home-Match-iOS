//
//  RealitorAPI.swift
//  Home Match
//
//  Created by Sterling Gamble on 4/4/21.
//

import Foundation

class RealitorAPI {
    var headers = [
        "x-rapidapi-key": realitorAPIKey,
        "x-rapidapi-host": "realtor.p.rapidapi.com"
    ]
    
    func autoComplete(text: String, completion: @escaping ([Dictionary<String, Any>]) -> (Void)) {
        var replaced = text.replacingOccurrences(of: " ", with: "%20")
        replaced = replaced.replacingOccurrences(of: ",", with: "%2C")
        let url = "https://realtor.p.rapidapi.com/locations/auto-complete?input=\(replaced)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            do {
                let response = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                completion(response["autocomplete"] as! [Dictionary<String, Any>])
            } catch {
                print(error)
            }
        }
        
        task.resume()
        
    }
    
    func propertiesForSale(city: String, state: String, completion: @escaping ([Dictionary<String, Any>]) -> (Void)) {
        var url = "https://realtor.p.rapidapi.com/properties/v2/list-for-sale?"
        url += "city=" + city.replacingOccurrences(of: " ", with: "%20")
        url += "&limit=20&offset=0"
        url += "&state_code=\(state)&sort=relevance"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            do {
                let response = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                completion(response["properties"] as! [Dictionary<String, Any>])
            } catch {
                print("JSON Error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
        
    }
}
