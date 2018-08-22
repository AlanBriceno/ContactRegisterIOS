//
//  ViewController.swift
//  ContactRegister
//
//  Created by Alan Briceño on 18/08/18.
//  Copyright © 2018 Alan Briceño. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    var countries = [Country]()
    var contacts = [Contact]()
    var finalResult: Codable?
    var selectedCountry: Codable?
    var image64String: String?
    
    @IBOutlet weak var inputCompany: UITextField!
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputLastName: UITextField!
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputPhoneNumber: UITextField!
    
    @IBOutlet weak var pendingContactLabel: UILabel!
    
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnAddMore: UIButton!
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadJsonCountry()
        inputCompany.delegate = self
        inputEmail.delegate = self
        inputLastName.delegate = self
        inputName.delegate = self
        inputPhoneNumber.delegate = self
        pendingContactLabel.text = ""
        tblView.isHidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func encodeContact(){
        let finalCountry = selectedCountry
        let finalNumber = PhoneNumbers(Country: finalCountry as! Country, Number: inputPhoneNumber.text!)
        let contact = Contact(Company: inputCompany.text!, EmailsAddress: [inputEmail.text!], LastName: inputLastName.text!, Name: inputName.text!, PhoneNumbers: [finalNumber], Photo: image64String!)
        
        self.contacts.append(contact)
        clearFields()
        pendingContacts()
        
    }
    
    fileprivate func encodeFinalResult(){
        if contacts.isEmpty {
            
            if isValidData() {
                let finalCountry = selectedCountry
                let finalNumber = PhoneNumbers(Country: finalCountry as! Country, Number: inputPhoneNumber.text!)
                let contact = Contact(Company: inputCompany.text!, EmailsAddress: [inputEmail.text!], LastName: inputLastName.text!, Name: inputName.text!, PhoneNumbers: [finalNumber], Photo: image64String!)
                let finalRegistry = ContactsResult(Contacts: [contact], Location: Location(Latitude: 15, Longitude: 15), RegisteredBy: RegisteredBy(Name: "Alan Alexis Briceño"), Type: 1)
                
                submitPost(post: finalRegistry) { (error) in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                }
                clearFields()
                self.contacts.removeAll()
                pendingContactLabel.text = ""
            }
            
        } else {
            
            if isValidData() {
                encodeContact()
                let finalRegistry = ContactsResult(Contacts: contacts, Location: Location(Latitude: 15, Longitude: 15), RegisteredBy: RegisteredBy(Name: "Alan Alexis Briceño"), Type: 1)
                
                submitPost(post: finalRegistry) { (error) in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                }
                self.contacts.removeAll()
                pendingContactLabel.text = ""
                
            }
            
        }
        
    }
    
    fileprivate func submitPost(post: ContactsResult, completion:((Error?) -> Void)?) {

        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
    
        let urlString = "https://contactmanager.banlinea.com/api/ContactRegister/"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers

        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(post)
            
            request.httpBody = jsonData
        } catch {
            completion?(error)
        }

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                completion?(responseError!)
                return
            }

            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
                self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                let alertController = UIAlertController(title: "Congratulations!", message: "Contacts added", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    DispatchQueue.main.async
                        {
                            self.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
                
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
    }
    
    fileprivate func downloadJsonCountry() {
        let urlString = "https://contactmanager.banlinea.com/api/countries"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to get data from url:", err)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    self.countries = try decoder.decode([Country].self, from: data)
                    self.tblView.reloadData()
                } catch let jsonErr {
                    print("Failed to decode:", jsonErr)
                }
            }
            }.resume()
    }

    @IBAction func onClickCountryButton(_ sender: Any) {
        if tblView.isHidden{
            animate(toogle: true)
        } else {
            animate(toogle: false)
        }
    }
    
    func animate(toogle: Bool) {
        if toogle {
            UIView.animate(withDuration: 0.3) {
                self.tblView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.tblView.isHidden = true
            }
        }
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imageController, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = chosenImage
        let quality = 0
        let base64String = (UIImageJPEGRepresentation(chosenImage!, CGFloat(quality))?.base64EncodedString())!
        image64String = base64String
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickRegisterBtn(_ sender: UIButton) {
        encodeFinalResult()
    }
    
    @IBAction func onClickAddMoreBtn(_ sender: UIButton) {
        
        if (isValidData()) {
            encodeContact()
        }
        
    }
    
    func isValidData() -> Bool {
        if (inputCompany.text?.isEmpty)! ||
            (inputName.text?.isEmpty)! ||
            (inputEmail.text?.isEmpty)! ||
            (inputLastName.text?.isEmpty)! ||
            (inputPhoneNumber.text?.isEmpty)! ||
            (btnCountry.currentTitle! == "Select Country")
        {
            displayMessage(userMessage: "All fields are quired to fill in")
            return false
        }
        
        if imageView.image == nil {
            displayMessage(userMessage: "Select an image")
            return false
        }
        
        if !isValidEmail(inputEmail.text!){
            displayMessage(userMessage: "Invalid Email")
            return false
        }
        
        if !isValidString(inputName.text!) {
            displayMessage(userMessage: "Invalid Name, use only letters")
            return false
        }
        
        if !isValidString(inputLastName.text!) {
            displayMessage(userMessage: "Invalid Name, use only letters")
            return false
        }
        
        if !isValidNumber(inputPhoneNumber.text!) {
            displayMessage(userMessage: "Invalid Phone, use only numbers")
            return false
        }
        
        return true
    }
    
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async
            {
                let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    DispatchQueue.main.async
                        {
                            self.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }
    
    func clearFields(){
        inputCompany.text = ""
        inputEmail.text = ""
        inputLastName.text = ""
        inputName.text = ""
        inputPhoneNumber.text = ""
        
        btnCountry.setTitle("Select Country", for: .normal)
        
        imageView.image = nil
    }
    
    func pendingContacts(){
        let count =  contacts.count
        pendingContactLabel.text = "Pending contancs: \(count)"
    }
    
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView)
    {
        DispatchQueue.main.async
            {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputCompany.resignFirstResponder()
        print("tapped")
        inputEmail.resignFirstResponder()
        inputLastName.resignFirstResponder()
        inputName.resignFirstResponder()
        inputPhoneNumber.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row].Name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnCountry.setTitle("\(countries[indexPath.row].Name)", for: .normal)
        animate(toogle: false)
        selectedCountry = Country(Code: countries[indexPath.row].Code, Name: countries[indexPath.row].Name)
    }
    
    
}

