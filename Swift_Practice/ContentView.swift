//
//  ContentView.swift
//  Swift_Practice
//
//  Swiftの「型」と「SwiftUIでの表示」をセットで理解するサンプルである。
//  - Swiftは静的型付け言語なので、変数には「型」が必ず付く。
//  - SwiftUIは View を「値（構造体）」として組み立て、宣言的にUIを記述する。
//  - ここでは Int の代入がOKで String の代入がNGであることを、UI上にも表示する構成にする。
//
//  Created by maton on 2026/02/23.
//

import SwiftUI

// MARK: - 型のデモ用の値（モデル）
//
// SwiftUIでは、画面に出す「状態（state）」を View の外にモデルとして切り出すと理解しやすい。
// ここでは「Int型の変数 a を持っている」という例を、アプリの状態として持たせる。
struct TypeDemoModel {
    // Int型の値を保持するプロパティである。
    // Int は整数型で、例: 0, 1, 456, -10 などを表せる。
    var a: Int
    
    // 「代入が成功する例」を関数として表現しておく。
    // Swiftは型が一致している場合のみ代入できるため、Int への Int 代入はOKである。
    mutating func assignIntExample() {
        a = 456
    }
    
    // 「代入が失敗する例」は、実コードに書くとコンパイルが止まるのでコメントで残す。
    // a = "abc" のように Int に String を入れようとするとコンパイルエラーになる。
    //
    // つまり「型が違う値は代入できない」というのが静的型付けの基本である。
}

// MARK: - SwiftUI View
//
// SwiftUIの画面は View プロトコルに準拠した構造体として書く。
// body は「この画面は何でできているか」を宣言する部分である。
// ここで重要なのは、UIが「状態（state）」から自動的に再描画される点である。
struct ContentView: View {
    // @State は「この値が変わったらUIを更新してね」というSwiftUIの仕組みである。
    // 今回は a を画面に表示して、ボタンで 456 に更新できるようにする。
    //
    // 注意:
    // - @State は View の内部状態を保持する用途であり、値が変わると body が再評価される。
    // - ここではモデルを丸ごと @State で持ち、a を更新する。
    @State private var model = TypeDemoModel(a: 0)
    
    var body: some View {
        VStack(spacing: 16) {
            // SF Symbols の "globe" を表示する例である。
            // Image(systemName:) はシステム提供のアイコン（SF Symbols）を表示する。
            Image(systemName: "globe")
                .imageScale(.large)          // 画像サイズのスケールを大きくする
                .foregroundStyle(.tint)      // テーマカラー（tint）を適用する
            
            // 現在の a の値を画面に表示する。
            // \(...) は文字列補間（String interpolation）であり、
            // Int を String に変換して文中に埋め込む。
            Text("a の値: \(model.a)")
                .font(.title2)
            
            // 「Int型の代入はOK」をUI操作で確認できるようにボタンを置く。
            Button("a に 456（Int）を代入する") {
                // ここで model.a を 456 に変更する。
                // @State の値が変化するので、SwiftUIが自動で Text を更新する。
                model.assignIntExample()
            }
            .buttonStyle(.borderedProminent)
            
            // 「String を代入しようとするとコンパイルエラー」を説明として表示する。
            // 実際に a = "abc" を書くとビルドが通らなくなるため、コメントとして示す。
            VStack(alignment: .leading, spacing: 8) {
                Text("メモ")
                    .font(.headline)
                Text("・Swiftは静的型付けなので、Int型の変数にはIntしか代入できない。")
                Text("・例えば a = \"abc\" は Int と String の型が一致しないためコンパイルエラーになる。")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
}

// MARK: - Preview
//
// #Preview は Xcode のプレビュー表示用である。
// 実行せずにUIを確認できるので、SwiftUI開発では頻繁に使う。
#Preview {
    ContentView()
}
