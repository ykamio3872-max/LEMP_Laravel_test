<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Request;

// 1. トップページ
Route::get('/', function () {
    return view('welcome');
});

// 2. 画像アップロード処理
Route::post('/upload', function (Request $request) {
    $request->validate([
        'image' => 'required|image|max:2048',
    ]);

    try {
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            
            // S3(LocalStack)に保存
            $path = Storage::disk('s3')->putFile('uploads', $file, 'public');

            // URLを取得し、ブラウザ閲覧用に 'aws:4566' を 'localhost:4566' に置換
            $url = Storage::disk('s3')->url($path);
            $displayUrl = str_replace('aws:4566', 'localhost:4566', $url);

            return view('welcome', ['url' => $displayUrl]);
        }
    } catch (\Exception $e) {
        return back()->withErrors('アップロード失敗: ' . $e->getMessage());
    }
});

// 3. 画像削除処理
Route::post('/delete', function (Request $request) {
    $path = $request->input('path');

    try {
        if ($path && Storage::disk('s3')->exists($path)) {
            Storage::disk('s3')->delete($path);
            return redirect('/')->with('status', '画像を削除しました。');
        }
    } catch (\Exception $e) {
        return back()->withErrors('削除失敗: ' . $e->getMessage());
    }

    return back()->withErrors('ファイルが見つかりませんでした。');
});

// 4. 通信テスト用
Route::get('/s3-upload-test', function () {
    try {
        Storage::disk('s3')->put('test.txt', 'Connection OK');
        return response()->json(['status' => 'Success', 'content' => Storage::disk('s3')->get('test.txt')]);
    } catch (\Exception $e) {
        return response()->json(['status' => 'Error', 'message' => $e->getMessage()], 500);
    }
});