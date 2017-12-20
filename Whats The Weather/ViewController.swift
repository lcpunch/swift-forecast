//
//  ViewController.swift
//  Whats The Weather
//
//  Created by MAC on 2017-12-19.
//  Copyright © 2017 lcpunch. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var parser = XMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    var dataStruct:Root? = nil

    @IBOutlet weak var tableWeather: UITableView!
    @IBOutlet weak var cityTextField: UITextField!
  
    struct Root: Codable {
        let cod: String
        let message: Double
        let cnt: Int
        struct List: Codable {
            let dt: Double
            struct Main: Codable {
                let temp: Double
                let temp_min: Double
                let temp_max: Double
                let pressure: Double
                let sea_level: Double
                let grnd_level: Double
                let humidity: Double
                let temp_kf: Double
            }
            
            let main: Main
            struct Weather: Codable {
                let id: Int
                let main: String
                let description: String
                let icon: String
            }
            
            let weather: [Weather]
            
            let dt_txt: String
        }
        struct City: Codable {
            let id: Int
            let name: String
            struct Coord: Codable{
                let lat: Double
                let lon: Double
            }
            let coord: Coord
            let country: String
        }
        let list: [List]
        let city: City
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataStruct != nil {
            return dataStruct!.cnt
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = (self.tableWeather.dequeueReusableCell(withIdentifier: "cell"))!
        cell.backgroundColor = UIColor.clear
        
        if dataStruct == nil {
            return cell
        }
        
        if let labelTitle = cell.viewWithTag(10) as! UILabel! {

            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm MMM dd,yyyy"
            
            let date: Date? = dateFormatterGet.date(from: (dataStruct?.list[indexPath.row].dt_txt)!)
            
            labelTitle.text = dateFormatter.string(from: date!)
        }
        
        if let labelTitle = cell.viewWithTag(40) as! UILabel! {
            
            let description = dataStruct?.list[indexPath.row].weather[0].description
            
            labelTitle.text = description!
        }
        
        if let labelTitle = cell.viewWithTag(30) as! UILabel! {
            
            var min = dataStruct?.list[indexPath.row].main.temp_min
            
            min = min! - 273.15
            
            labelTitle.text = String(format:"%.2f", min!)
        }
        
        if let labelTitle = cell.viewWithTag(20) as! UILabel! {
            
            var max = dataStruct?.list[indexPath.row].main.temp_max
            
            max = max! - 273.15
            
            labelTitle.text = String(format:"%.2f", max!)
        }
        
        return cell

    }
    
    let rootURL = "https://api.openweathermap.org/data/2.5/forecast?appid=c755bd4a9e5ad29dcb006a96e159724e"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func searchWeather(_ sender: Any) {
        
        if cityTextField.text == "" {
            return
        }

        var city = cityTextField.text!
        city = city.trimmingCharacters(in: .whitespacesAndNewlines)
        city = city.folding(options: .diacriticInsensitive, locale: .current)
        
        let url = URL(string: "\(rootURL)&q=\(String(describing: city))")
        
        
        print("\(rootURL)&q=\(String(describing: city))")
        let request = NSMutableURLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if let error = error {
                print(error)
            } else {
                if let unwrappedData = data {

                    let decoder = JSONDecoder()
                    DispatchQueue.main.sync(execute: {
                        self.dataStruct = try! decoder.decode(Root.self, from: unwrappedData)
                        self.tableWeather.reloadData()

                    })
                    
                }
            }
        }
        task.resume()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
