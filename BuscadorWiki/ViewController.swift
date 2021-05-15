//
//  ViewController.swift
//  BuscadorWiki
//
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var wordSearch: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchButton(_ sender: Any) {
        if wordSearch.text != "" {
            print(wordSearch.text!)
            searchWiki(word: wordSearch.text!)
        }
    }
    
    func searchWiki(word: String){
        // URL del API a consultar
        let urlAPI = URL(string: "https://es.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&titles=\(word.replacingOccurrences(of: " ", with: "%20"))")
        
        // Peticion a la API
        let peticion = URLRequest(url: urlAPI!)
        
        // Creacion de la tarea
        let task = URLSession.shared.dataTask(with: peticion) {data, response, error in
            // Verificacion de si exise un error al realizar la peticion
            if error != nil {
                print(error!)
            } else {
                do{
                   let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    
                    let querySubJson = json["query"] as! [String: Any]
                    
                    let pagesSubJson = querySubJson["pages"] as! [String: Any]
                    
                    // Validar si existe algun resultado
                    if pagesSubJson.keys.first == "-1"{
                        DispatchQueue.main.sync(execute: {
                            self.webView.loadHTMLString("<h1>Sin Resultados</h1>", baseURL: nil)
                        })
                    } else {
                        let pageId = pagesSubJson.keys
                        
                        let keyExtract = pageId.first!
                        
                        let idSubJson = pagesSubJson[keyExtract] as! [String: Any]
                        
                        let extract = idSubJson["extract"] as! String
                        
                        if extract == "" {
                            DispatchQueue.main.sync(execute: {
                                self.webView.loadHTMLString("<h1>Sin Resultados para esta busqueda</h1>", baseURL: nil)
                            })
                        } else {
                            DispatchQueue.main.sync(execute: {
                                self.webView.loadHTMLString(extract, baseURL: nil)
                            })
                        }
                    }
                } catch{
                    print("Error al procesar el JSON \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}
