<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

Route::get('/', function () {
    return view('welcome');
});

// S3（LocalStack）への通信テスト用ルート
Route::get('/s3-upload-test', function () {
    $fileName = 'test-connection.txt';
    $content = 'LocalStack Connection Success! at ' . now();

    try {
        // 1. 書き込みテスト
        Storage::disk('s3')->put($fileName, $content);

        // 2. 読み込みテスト
        $readContent = Storage::disk('s3')->get($fileName);

        return response()->json([
            'status' => 'Success',
            'message' => 'AWS(LocalStack)との通信に成功しました！',
            'retrieved_content' => $readContent,
            'endpoint' => env('AWS_ENDPOINT'),
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'status' => 'Error',
            'message' => '通信に失敗しました。',
            'error' => $e->getMessage(),
        ], 500);
    }
});