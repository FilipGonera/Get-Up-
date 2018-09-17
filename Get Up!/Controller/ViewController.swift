//
//  ViewController.swift
//  Get Up!
//
//  Created by Filip  Gonera on 20/08/2018.
//  Copyright © 2018 Filip  Gonera. All rights reserved.
//


import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var frequencyPicker: UIDatePicker!
    @IBOutlet weak var notifiactionCountLabel: UILabel!
    
    let center = UNUserNotificationCenter.current()
    
    var frequencyTime: Double = 0
    var durationTime: Double = 0
    
    var pendingNotifications: Int = 0
    
    
    let greenColor = UIColor(red: 102.0/255.0, green: 204.0/255.0, blue: 0/255.0, alpha: 1.0)
    
    func setupStartBtnToStart(){
        startBtn.isSelected = false
        startBtn.backgroundColor = UIColor.clear
        startBtn.layer.borderColor = greenColor.cgColor
        startBtn.layer.borderWidth = 2
        startBtn.setTitleColor(greenColor, for: .normal)
        startBtn.setTitle("Start", for: .normal)
        startBtn.layer.cornerRadius = 40
    }
    
    func setupStartBtnToStop(){
        startBtn.isSelected = true
        startBtn.backgroundColor = UIColor.red
        startBtn.layer.borderWidth = 0
        startBtn.setTitleColor(UIColor.white, for: .normal)
        startBtn.setTitle("Stop", for: .normal)
        startBtn.layer.cornerRadius = 40
    }
    
    @IBAction func frequencyPickerChanged(_ sender: Any) {
        setupFrequency()
    }
    
    @IBAction func durationPickerChanged(_ sender: Any) {
        setupDuration()
    }
    
    @IBAction func startBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let selected = sender.isSelected
        
        if selected {
            scheduleNotification()
            checkPendingNotifications()
            setupStartBtnToStop()
        } else {
            cancelNotifications()
            checkPendingNotifications()
            print("notifications canceled")
            setupStartBtnToStart()
        }
    }
    
    func setupFrequency() {
        DispatchQueue.main.async {
            self.frequencyTime = self.frequencyPicker.countDownDuration
            print(self.frequencyTime)
        }
    }
    
    func setupDuration(){
        DispatchQueue.main.async {
        self.durationTime = self.durationPicker.countDownDuration
        let resultTime = round(self.durationTime/60)
        print("hours: \(resultTime)")
        }
    }
    
    func checkPendingNotifications(){
        center.getPendingNotificationRequests(completionHandler: { requests in
            DispatchQueue.main.async {
                if requests.count > 0 {
                 self.notifiactionCountLabel.text = "You have \(requests.count - 1) notifications set"
                 self.pendingNotifications = requests.count
                } else {
                    self.notifiactionCountLabel.text = "You have \(requests.count) notifications set"
                }
            }
            print("request number: \(requests.count)")
        })
    }
    
    func scheduleNotification(){
    
        let interval: Double = frequencyTime // frequency time selected by user
        let maxDuration: Double = durationTime // duration time selected by user
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(maxDuration)
        print(startDate)
        
        let notificationCount: Int = Int((endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970) / interval) + 1
        print(notificationCount)
        
        if notificationCount >= 64 { //this handles ios restriction of scheduling up to 64 notifications
            let alert = UIAlertController(title: "Slow down!", message: "You have created too many notifications", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            print("too many notifications")
        }else{
            (0..<notificationCount).map({ startDate.addingTimeInterval(Double($0) * interval) }).forEach({ date in //this setups start date of each notification delayed by multiplayed value of interval

                print(endDate.timeIntervalSince1970-startDate.timeIntervalSince1970)
                print(notificationCount)
                print("date from for each \(date)")
                
                
                //this setups image attachment
                let myImage = "GET UP"
                let imageURL = Bundle.main.url(forResource: myImage, withExtension: "jpg")
                
                var attachment: UNNotificationAttachment
                attachment = try! UNNotificationAttachment(identifier: UUID().uuidString, url: imageURL!, options: .none)
                
                let content = UNMutableNotificationContent()
                content.title = "Get up!"
                content.body = "It's time to move a little"
                content.categoryIdentifier = "get up"
                content.userInfo = ["customData": "custom"]
                content.sound = UNNotificationSound.default()
                content.attachments = [attachment]
                
                var components = DateComponents()
                components.year = Calendar.current.component(.year, from: date)
                components.month = Calendar.current.component(.month, from: date)
                components.day = Calendar.current.component(.day, from: date)
                components.hour = Calendar.current.component(.hour, from: date)
                components.minute = Calendar.current.component(.minute, from: date)
                components.second = Calendar.current.component(.second, from: date)
            
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request, withCompletionHandler: { error in
                    if error != nil {
                        print("error while setting up notification")
                    } else {
                        //notification set up successfully
                        DispatchQueue.main.async {
                        print("notifiaction setup succesfully on \(date)")
                    }
                    }
                })
            })
        }
    }
    
    
    
    func cancelNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("permission granted")
            } else {
                print("permission not granted")
            }
            self.setupFrequency()
            self.setupDuration()
        }
        setupStartBtnToStart()
        checkPendingNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

