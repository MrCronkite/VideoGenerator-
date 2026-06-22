//
//  Resources.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit


enum R {

    enum Colors {
        static let bgDark = UIColor.darkGray
        static let lightGray = UIColor.lightGray

        static let darkBrown = UIColor(hex: "#1F191F")

        static let blueGradient = UIColor(hex: "#98C6F7")
        static let pinkGradient = UIColor(hex: "#EB5B92")
        static let bgColor = UIColor(hex: "#0B070E")
    }

    enum Images {
        static let iconChat = UIImage(named: "icon.chat")
        static let iconTalk = UIImage(named: "icon.talk")
        static let iconUnderstand = UIImage(named: "icon.understand")
        static let iconVideo = UIImage(named: "icon.video")
        static let iconWrite = UIImage(named: "icon.write")
        static let iconMedia = UIImage(named: "icon.media")
        static let iconClose = UIImage(named: "icon.close")
        static let iconClock = UIImage(named: "icon.clock")
        static let bgGradient = UIImage(named: "bg.gradient")

        static let mainAsk = UIImage(named: "main.ask")
        static let mainBg = UIImage(named: "main.bg")
        static let mainIcon = UIImage(named: "main.icon")
        static let mainPlay = UIImage(named: "main.play")
        static let mainSettings = UIImage(named: "main.settings")
        static let mainVideo = UIImage(named: "main.video")
        static let mainSiri = UIImage(named: "main.siri")
        static let mainText = UIImage(named: "main.text")

        static let elipse = UIImage(named: "elipse")
        static let iconHistory = UIImage(named: "icon.history")
        static let arrowPop = UIImage(named: "arrow.pop")
        static let iconSend = UIImage(named: "icon.send")
        static let iconCheck = UIImage(named: "icon.check")
        static let iconReplace = UIImage(named: "icon.replace")
        static let iconCross = UIImage(named: "icon.cross")
        static let iconTemplates = UIImage(named: "icon.templates")
    }

    enum Network {

        enum API {
            static let baseURL = "https://nebulaapps.site"
            static let path = "/dola/chats"
        }

        enum Headers {
            static let contentType = "Content-Type"
            static let authorization = "Authorization"
            static let applicationJSON = "application/json"
        }

        enum QueryKeys {
            static let userId = "user_id"
            static let appId = "app_id"
        }

        enum AppInfo {
            static let appId = "com.test.test"
            static let defaultUserId = "Apphud"
        }
    }
}

enum NetworkConstants {

    enum API {
        static let baseURL = "https://nebulaapps.site"
        static let path = "/dola/chats"
    }

    enum Headers {
        static let contentType = "Content-Type"
        static let authorization = "Authorization"
        static let applicationJSON = "application/json"
    }

    enum Auth {
        static let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJzaGFyb3ZfMTk5OUBsaXN0LnJ1Iiwicm9sZSI6IkFETUlOIiwiZXhwIjo0OTM1MjA4NjcxLCJpYXQiOjE3ODE2MDg2NzEsInR5cGUiOiJhY2Nlc3MifQ.0GRnZq1LZA__0G0tYEsPER8lQiCiX_myE6_T_nMwUmc"
    }
}
