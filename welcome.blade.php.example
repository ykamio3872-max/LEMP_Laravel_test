<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>S3 Image Uploader</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Nunito', sans-serif; background-color: #f7fafc; color: #2d3748; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .container { background: white; padding: 2rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); width: 100%; max-width: 500px; }
        .upload-section { margin-bottom: 2rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 1rem; }
        .preview-section img { max-width: 100%; border-radius: 0.25rem; margin-top: 1rem; }
        .btn { color: white; border: none; padding: 0.5rem 1rem; border-radius: 0.25rem; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-primary { background: #4a5568; }
        .btn-danger { background: #e53e3e; margin-top: 1rem; }
        .alert { color: #e53e3e; margin-bottom: 1rem; font-size: 0.9rem; }
    </style>
</head>
<body class="antialiased">
    <div class="container">
        <div class="upload-section">
            <h2>画像をLocalStack S3へ保存</h2>
            
            @if($errors->any())
                <div class="alert">{{ $errors->first() }}</div>
            @endif

            <form action="/upload" method="POST" enctype="multipart/form-data">
                @csrf
                <div style="margin-bottom: 1rem;">
                    <input type="file" name="image" accept="image/*" required>
                </div>
                <button type="submit" class="btn btn-primary">アップロード実行</button>
            </form>
        </div>

        <div class="preview-section">
            <h3>プレビュー</h3>
            @if(isset($url))
                <p style="color: #48bb78;">アップロード成功！</p>
                <img src="{{ $url }}" alt="Uploaded Image">
                <p style="font-size: 0.7rem; color: #718096; word-break: break-all; margin-top: 0.5rem;">URL: {{ $url }}</p>

                {{-- 削除フォーム --}}
                <form action="/delete" method="POST">
                    @csrf
                    @php
                        // URLからバケット名以降のパス（uploads/xxx.jpg）を安全に抽出
                        $parts = explode('4566/' . env('AWS_BUCKET', 'my-test-bucket') . '/', $url);
                        $s3Path = end($parts);
                    @endphp
                    <input type="hidden" name="path" value="{{ $s3Path }}">
                    <button type="submit" class="btn btn-danger">この画像を削除する</button>
                </form>
            @else
                <p style="color: #a0aec0;">画像がアップロードされていません。</p>
            @endif
        </div>
    </div>
</body>
</html>