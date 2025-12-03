//
//  PostView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/20/25.
//

import SwiftUI

struct PostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var content: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    @FocusState private var isEditorFocused: Bool
    
    var gymTag: UUID?
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 18) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(.invertedPrimary)
                    }
                    Spacer()
                    
                    Text("New Post")
                        .fontWeight(.semibold)
                    Spacer()
                    Spacer()
                }
                .padding()
                
                Divider()
                
                VStack(alignment: .leading) {
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Say Hello!")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 2)
                                .padding(.vertical, 9)
                        }
                        
                        TextEditor(text: $content)
                            .scrollContentBackground(.hidden)
                            .focused($isEditorFocused)
                            .padding(.horizontal, -3)
                    }
                    
                }
                .padding(.horizontal)
                
                HStack {
                    Button {
                        Task {
                            do {
                                try await SupabaseManager.shared.createPost(content: content, gym_id: gymTag)
                                
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        Text("Post")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 50)
                            .padding()
                            .background(Color.brandOrange)
                            .cornerRadius(30)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                DispatchQueue.main.async {
                    isEditorFocused = true
                }
            }
        }
        
    }
}

struct EditingPostView: View {
    @Environment(\.dismiss) var dismiss
    let post_id: UUID
    @State var content: String
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 18) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(.invertedPrimary)
                    }
                    Spacer()
                    
                    Text("Editing Post")
                        .fontWeight(.semibold)
                    Spacer()
                    Spacer()
                }
                .padding()
                
                Divider()
                
                VStack(alignment: .leading) {
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Say Hello!")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 2)
                                .padding(.vertical, 9)
                        }
                        
                        TextEditor(text: $content)
                            .scrollContentBackground(.hidden)
                            .focused($isEditorFocused)
                            .padding(.horizontal, -3)
                    }
                    
                }
                .padding(.horizontal)
                
                HStack {
                    Button {
                        Task {
                            do {
                                try await SupabaseManager.shared.updatePost(post_id: post_id, content: content)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        Text("Post")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 50)
                            .padding()
                            .background(content.isEmpty ? Color.standardSecondary: Color.brandOrange)
                            .cornerRadius(30)
                    }
                }
                .disabled(content.isEmpty)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                DispatchQueue.main.async {
                    isEditorFocused = true
                }
            }
        }
        
    }
}

#Preview {
    PostView()
}
