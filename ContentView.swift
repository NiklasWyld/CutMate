//
//  ContentView.swift
//  CutMate
//
//  Created by Niklas on 27.11.23.
//

import SwiftUI

struct Copy: Identifiable, Equatable {
    let content: String
    let id = UUID()
}

class Copies: ObservableObject {
    @Published public var clipboard: [Copy] = []
}

func formatString(_ input: String) -> String {
    var formattedString = input.trimmingCharacters(in: .whitespacesAndNewlines)

    formattedString = formattedString.replacingOccurrences(of: "^\t+", with: " ", options: .regularExpression)

    if formattedString.count > 80 {
        let endIndex = formattedString.index(formattedString.startIndex, offsetBy: 80)
        formattedString = String(formattedString[..<endIndex]) + "..."
    }

    return formattedString
}

struct CopyPanel: View {
    @ObservedObject var copies = Copies()
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                ScrollView {
                    ForEach(copies.clipboard) { copy in
                        HStack {
                            Button(action: {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(copy.content, forType: .string)
                            }) {
                                HStack {
                                    Text(formatString(copy.content))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .id(copy.id)
                            Menu {
                                Button(action: {
                                    if let index = self.copies.clipboard.firstIndex(where: { $0.id == copy.id }) {
                                        self.copies.clipboard.remove(at: index)
                                    }
                                }) {
                                    Text("Entfernen")
                                    Image(systemName: "minus.circle")
                                        .font(.system(size: 24))
                                        .padding()
                                        .foregroundColor(.white)
                                }

                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.system(size: 24))
                                    .padding()
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: 45)
                        }
                    }
                    .padding()
                    .onChange(of: copies.clipboard.count) {
                        if(copies.clipboard.count != 0) {
                            proxy.scrollTo(copies.clipboard.first!.id)
                        }
                    }
                }
                Button("Clear history") {
                    copies.clipboard.removeAll()
                }
            }
        }
    }
}

struct ControlPanel: View {
    var body: some View {
        VStack {
            
        }
    }
}

#Preview {
    CopyPanel()
}
