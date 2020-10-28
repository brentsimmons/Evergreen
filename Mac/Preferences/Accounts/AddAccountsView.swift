//
//  AddAccountsView.swift
//  NetNewsWire
//
//  Created by Stuart Breckenridge on 28/10/20.
//  Copyright © 2020 Ranchero Software. All rights reserved.
//

import SwiftUI
import Account

private enum AddAccountSections: Int, CaseIterable {
	case local = 0
	case icloud
	case web
	case selfhosted
	
	var sectionHeader: String {
		switch self {
		case .local:
			return NSLocalizedString("Local", comment: "Local Account")
		case .icloud:
			return NSLocalizedString("iCloud", comment: "iCloud Account")
		case .web:
			return NSLocalizedString("Web", comment: "Web Account")
		case .selfhosted:
			return NSLocalizedString("Self-hosted", comment: "Self hosted Account")
		}
	}
	
	var sectionFooter: String {
		switch self {
		case .local:
			return NSLocalizedString("This account does not sync subscriptions across devices.", comment: "Local Account")
		case .icloud:
			return NSLocalizedString("Use your iCloud account to sync your subscriptions across your iOS and macOS devices.", comment: "iCloud Account")
		case .web:
			return NSLocalizedString("Web accounts sync your subscriptions across all your devices.", comment: "Web Account")
		case .selfhosted:
			return NSLocalizedString("Self-hosted accounts sync your subscriptions across all your devices.", comment: "Self hosted Account")
		}
	}
	
	var sectionContent: [AccountType] {
		switch self {
		case .local:
			return [.onMyMac]
		case .icloud:
			return [.cloudKit]
		case .web:
			return [.bazQux, .feedbin, .feedly, .feedWrangler, .inoreader, .newsBlur, .theOldReader]
		case .selfhosted:
			return [.freshRSS]
		}
	}
}

struct AddAccountsView: View {
    
	weak var parent: NSHostingController<AddAccountsView>? // required because presentationMode.dismiss() doesn't work
	var addAccountDelegate: AccountsPreferencesAddAccountDelegate?
	init(delegate: AccountsPreferencesAddAccountDelegate?) {
		self.addAccountDelegate = delegate
	}
	@State private var selectedAccount: AccountType = .onMyMac
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Choose an account type to add...")
				.font(.headline)
				.padding()
			
			localAccount
			icloudAccount
			webAccounts
			selfhostedAccounts
			
			HStack {
				Spacer()
				if #available(OSX 11.0, *) {
					Button(action: {
						parent?.dismiss(nil)
					}, label: {
						Text("Cancel")
							.accessibility(label: Text("Add Account"))
					}).keyboardShortcut(.cancelAction)
				} else {
					Button(action: {
						parent?.dismiss(nil)
					}, label: {
						Text("Cancel")
							.accessibility(label: Text("Add Account"))
					})
				}
				if #available(OSX 11.0, *) {
					Button(action: {
						addAccountDelegate?.presentSheetForAccount(selectedAccount)
						parent?.dismiss(nil)
					}, label: {
						Text("Continue")
					}).keyboardShortcut(.defaultAction)
				} else {
					Button(action: {
						addAccountDelegate?.presentSheetForAccount(selectedAccount)
						parent?.dismiss(nil)
					}, label: {
						Text("Continue")
					})
				}
			}.padding([.top, .bottom], 4)
		}
		.pickerStyle(RadioGroupPickerStyle())
		.fixedSize(horizontal: false, vertical: true)
		.frame(width: 400)
		.padding(12)
    }
	
	var localAccount: some View {
		VStack(alignment: .leading) {
			Text("Local")
				.font(.headline)
				.padding(.horizontal)
			Picker(selection: $selectedAccount, label: Text(""), content: {
				ForEach(AddAccountSections.local.sectionContent, id: \.self, content: { account in
					HStack(alignment: .top) {
						Image(nsImage: AppAssets.image(for: account)!)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 25, height: 25, alignment: .center)
							.offset(CGSize(width: 0, height: -2.5))
							
						VStack(alignment: .leading, spacing: 4) {
							Text(account.localizedAccountName())
							Text(AddAccountSections.local.sectionFooter).foregroundColor(.gray)
								.font(.caption)
						}
					}
					.tag(account)
				})
			})
			.pickerStyle(RadioGroupPickerStyle())
		}
		
	}
	
	var icloudAccount: some View {
		VStack(alignment: .leading) {
			Text("iCloud")
				.font(.headline)
				.padding(.horizontal)
			Picker(selection: $selectedAccount, label: Text(""), content: {
				ForEach(AddAccountSections.icloud.sectionContent, id: \.self, content: { account in
					HStack(alignment: .top) {
						Image(nsImage: AppAssets.image(for: account)!)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 25, height: 25, alignment: .center)
							.offset(CGSize(width: 0, height: -5))
							
						VStack(alignment: .leading, spacing: 4) {
							Text(account.localizedAccountName())
							Text(AddAccountSections.icloud.sectionFooter).foregroundColor(.gray)
								.font(.caption)
						}
					}
					.tag(account)
				})
			})
			.disabled(isCloudInUse())
		}
	}
	
	var webAccounts: some View {
		VStack(alignment: .leading) {
			Text("Web")
				.font(.headline)
				.padding(.horizontal)
			Picker(selection: $selectedAccount, label: Text(""), content: {
				ForEach(AddAccountSections.web.sectionContent.filter({ isRestricted($0) != true }), id: \.self, content: { account in
					
					HStack(alignment: .center) {
						Image(nsImage: AppAssets.image(for: account)!)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 25, height: 25, alignment: .center)
							
						VStack(alignment: .leading) {
							Text(account.localizedAccountName())
						}
					}
					.tag(account)
					
				})
			})
		}
	}
	
	var selfhostedAccounts: some View {
		VStack(alignment: .leading) {
			Text("Self-hosted")
				.font(.headline)
				.padding(.horizontal)
			Picker(selection: $selectedAccount, label: Text(""), content: {
				ForEach(AddAccountSections.selfhosted.sectionContent, id: \.self, content: { account in
					HStack {
						Image(nsImage: AppAssets.image(for: account)!)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 25, height: 25, alignment: .center)

						Text(account.localizedAccountName())
					}.tag(account)
				})
			})
			
			Text("Web and self-hosted accounts sync across all signed-in devices.")
				.font(.caption)
				.padding(.leading, 62)
				.foregroundColor(.gray)
		}
	}
	
	private func isCloudInUse() -> Bool {
		AccountManager.shared.accounts.contains(where: { $0.type == .cloudKit })
	}
	
	private func isRestricted(_ accountType: AccountType) -> Bool {
		if AppDefaults.shared.isDeveloperBuild && (accountType == .feedly || accountType == .feedWrangler || accountType == .inoreader) {
			return true
		}
		return false
	}
}


struct AddAccountsView_Previews: PreviewProvider {
	static var previews: some View {
		AddAccountsView(delegate: nil)
	}
}
