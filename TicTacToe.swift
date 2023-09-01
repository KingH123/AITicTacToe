//
//  ContentView.swift
//  TicTacToe
//
//  Created by Henry Tsui on 6/17/23.
//  Baruch College - henrytsui365@gmail.com
//
//

import SwiftUI

struct ContentView: View {
    @State private var board: [[String]] = Array(repeating: Array(repeating: "", count: 3), count: 3)
    @State private var currentPlayer = ""
    @State private var aiSymbol = ""
    @State private var gameOver = false
    @State private var winner = ""
    @State private var darkMode = false
    @State private var aiGame = false
    @State private var gameModeSelected = false
    @State private var draw = false
    @State private var player1Score = 0
    @State private var player2Score = 0
    @State private var aiScore = 0
    @State private var yourScore = 0
    @State private var symbolSelected = false
    @State private var symbolSet: [String] = []
    @State private var symbolOptions: [String] = ["X", "O", "🐶", "🐱", "🔥", "💧"]

    
    
    var body: some View {
        VStack(spacing: 10) {
            Toggle("Dark mode", isOn: $darkMode)
                .padding()
            
            HStack {
                if gameModeSelected {
                    Button("Restart") {
                        resetGame()
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text("Tic Tac Toe")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if gameModeSelected {
                gameBoard
                if aiGame {
                    HStack {
                        ScoreView(title: "Your Score", score: yourScore)
                            .padding()
                        ScoreView(title: "AI Score", score: aiScore)
                            .padding()
                    }
                } else {
                    HStack {
                        ScoreView(title: "Player 1 Score", score: player1Score)
                            .padding()
                        ScoreView(title: "Player 2 Score", score: player2Score)
                            .padding()
                    }
                }
            } else if symbolSelected {
                symbolSelectionView
            } else {
                gameModeSelection
            }
        }
        .preferredColorScheme(darkMode ? .dark : .light)
    }
    
    private var gameModeSelection: some View {
        VStack {
            Button("Play against AI") {
                aiGame = true
                symbolSelected = true
            }
            .padding()
            
            Button("Multiplayer") {
                aiGame = false
                symbolSelected = true
            }
            .padding()
        }
    }
    
    private var symbolSelectionView: some View {
        VStack {
            Text("Select your two Symbols")
                .font(.headline)
            
            HStack {
                ForEach(symbolOptions, id: \.self) { symbol in
                    Button(action: {
                        if symbolSet.count < 2 {
                            symbolSet.append(symbol)
                            if symbolSet.count == 2 {
                                symbolSelected = false
                                gameModeSelected = true
                                currentPlayer = symbolSet[0]
                                aiSymbol = symbolSet[1]
                                if aiGame && currentPlayer == aiSymbol {
                                    makeAIMove()
                                }
                            }
                        }
                    }) {
                        Text(symbol)
                            .font(.largeTitle)
                            .padding()
                            .background(darkMode ? Color.black : Color.gray)
                            .foregroundColor(darkMode ? .white : .black)
                            .border(Color.white, width: 2)
                    }
                }
            }
            
            if symbolSet.count >= 2 {
                Button("Reset Symbols") {
                    resetSymbols()
                }
                .padding()
            }
        }
    }
    
    private var gameBoard: some View {
        VStack {
            ForEach(0..<3) { i in
                HStack(spacing: 10) {
                    ForEach(0..<3) { j in
                        Button(action: {
                            if board[i][j] == "" && !gameOver {
                                board[i][j] = currentPlayer
                                checkForWinner()
                                if !gameOver && !draw {
                                    currentPlayer = currentPlayer == symbolSet[0] ? symbolSet[1] : symbolSet[0]
                                    if aiGame && currentPlayer == aiSymbol {
                                        makeAIMove()
                                    }
                                }
                            }
                        }) {
                            Text(board[i][j])
                                .font(.system(size: 50))
                                .frame(width: 70, height: 70)
                                .background(darkMode ? Color.black : Color.gray)
                                .foregroundColor(darkMode ? .white : .black)
                                .border(Color.white, width: 2)
                        }
                    }
                }
            }
            
            if gameOver {
                Text("\(winner) wins!")
                    .font(.title)
                    .padding()
                    .onAppear {
                        updateScores()
                    }
            } else if draw {
                Text("It's a draw!")
                    .font(.title)
                    .padding()
            }
            
            if gameOver || draw {
                Button("Back") {
                    resetGame()
                    gameModeSelected = false
                }
                .padding()
            }
        }
    }
    
    private func makeAIMove() {
        var availableMoves: [(Int, Int)] = []
        for i in 0..<3 {
            for j in 0..<3 {
                if board[i][j] == "" {
                    availableMoves.append((i, j))
                }
            }
        }
        
        guard !availableMoves.isEmpty else {
            return
        }
        
        let randomIndex = Int.random(in: 0..<availableMoves.count)
        let (row, col) = availableMoves[randomIndex]
        
        board[row][col] = currentPlayer
        checkForWinner()
        if !gameOver && !draw {
            currentPlayer = currentPlayer == symbolSet[0] ? symbolSet[1] : symbolSet[0]
        }
    }
    
    private func checkForWinner() {
        let lines = [
            [(0, 0), (0, 1), (0, 2)],
            [(1, 0), (1, 1), (1, 2)],
            [(2, 0), (2, 1), (2, 2)],
            [(0, 0), (1, 0), (2, 0)],
            [(0, 1), (1, 1), (2, 1)],
            [(0, 2), (1, 2), (2, 2)],
            [(0, 0), (1, 1), (2, 2)],
            [(0, 2), (1, 1), (2, 0)]
        ]
        
        for line in lines {
            if board[line[0].0][line[0].1] != "" &&
                board[line[0].0][line[0].1] == board[line[1].0][line[1].1] &&
                board[line[0].0][line[0].1] == board[line[2].0][line[2].1] {
                gameOver = true
                winner = board[line[0].0][line[0].1]
                return
            }
        }
        
        draw = true
        for i in 0..<3 {
            for j in 0..<3 {
                if board[i][j] == "" {
                    draw = false
                }
            }
        }
    }
    
    private func resetGame() {
        board = Array(repeating: Array(repeating: "", count: 3), count: 3)
        gameOver = false
        draw = false
        currentPlayer = symbolSet[0]
        if aiGame && currentPlayer == aiSymbol {
            makeAIMove()
        }
    }
    
    private func updateScores() {
        if aiGame {
            if winner == symbolSet[0] {
                yourScore += 1
            } else {
                aiScore += 1
            }
        } else {
            if winner == symbolSet[0] {
                player1Score += 1
            } else {
                player2Score += 1
            }
        }
    }
    
    private func resetSymbols() {
        symbolSet = []
    }
}

struct ScoreView: View {
    let title: String
    let score: Int
    
    var body: some View {
        VStack {
            Text(title)
            Text("\(score)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}





