import KayakoSDKSwift
import Utility
import Basic
import Foundation
import Alamofire //
//if stdoutStream is LocalFileOutputByteStream {
//
//	let progressBar = createProgressBar(forStream: stdoutStream, header: "Fetching dependencies")
//	for i in 1...100 {
//		progressBar.update(percent: i, text: "Vapor")
//		sleep(1)
//	}
//
//	progressBar.complete()
//}



let parser = ArgumentParser(commandName: "replicate", usage: "--url your-kayako-url --email your-email --password your-password --otp your-otp", overview: "Replicating https://kayako.atlassian.net/browse/PDM-11981")

let kURL = parser.add(option: "--url", shortName: "-u", kind: String.self, usage: "Your Kayako URL")
let kEmail = parser.add(option: "--email", shortName: "-e", kind: String.self, usage: "Your Kayako email")
let kPassword = parser.add(option: "--password", shortName: "-p", kind: String.self, usage: "Your Kayako password")

let args = Array(CommandLine.arguments.dropFirst())

do {
	let result = try parser.parse(args)
	
	let email = result.get(kEmail)!
	let password = result.get(kPassword)!
	let url = result.get(kURL)!
	
	let loginClient = Login()
	let fingerprint = UUID()
	loginClient.makeLoginRequest(url, email: email, password: password, fingerprint: fingerprint, completionHandler: { (loginResult) in
		if case .success = loginResult.resultState, let _ = loginResult.sessionID {
			print("logged In")
		} else if loginResult.resultState == .needs2FA, let reAuthToken = loginResult.reAuthToken {
			print("please enter 2FA code")
			let twoFACode = readLine(strippingNewline: true)
			loginClient.makeOTPRequest(url, twoFAOTP: twoFACode!, twoFAToken: reAuthToken, fingerprint: fingerprint, completionHandler: { (twoFAResult) in
				if case .success = twoFAResult.resultState, let sessionID = twoFAResult.sessionID {
					let sessionHandler = SessionHandler.init(baseURL: url, fingerprint: fingerprint, sessionID: sessionID, rememberMeToken: "", onReloading: { _ in })
					Alamofire.SessionManager.default.adapter = sessionHandler
					let client = Client(baseURL: url)
					let req = client.getAllViews(offset: 0, limit: 0) {
						(caseViews, error) in
						if error == nil {
							print("bug fixed")
						} else {
							print((error! as NSError).userInfo["JSON"] as Any)
						}
						exit(0)
					}
					print("🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨  Request to test with 🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨")
					print(req.debugDescription)
				} else {
					print(twoFAResult.error)
					print((twoFAResult.error as NSError?)?.userInfo as Any)
				}
			})
		} else {
			print((loginResult.error as NSError?)?.userInfo as Any)
		}
	})
	RunLoop.current.run()
	
} catch ArgumentParserError.expectedValue(let value) {
	print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(_, let stringArray) {
	print("Missing arguments: \(stringArray.joined()).")
} catch {
	print(error)
}

