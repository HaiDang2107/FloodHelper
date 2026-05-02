from flask import Flask, request, jsonify
import jwt
import time
import base64

app = Flask(__name__)

# Cấu hình username, password hợp lệ và secret key
VALID_USERNAME = 'customer-vietqrtest-user2468'
VALID_PASSWORD = 'Y3VzdG9tZXItdmlldHFydGVzdC11c2VyMjQ2ODpZM1Z6ZEc5dFpYSXRkbWxsZEhGeWRHVnpkQzExYzJWeU1qUTJPQT09' # Base64 của username:password
SECRET_KEY = 'your-256-bit-secret'  # Secret key để ký JWT

# API để tạo token
@app.route('/vqr/api/token_generate', methods=['POST'])
def generate_token():
    # Kiểm tra Authorization header
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith('Basic '):
        return jsonify({"error": "Authorization header is missing or invalid"}), 400

    # Giải mã Base64 từ Authorization header
    base64_credentials = auth_header.split(' ')[1]
    credentials = base64.b64decode(base64_credentials).decode('utf-8')
    username, password = credentials.split(':')

    # Kiểm tra username và password
    if username == VALID_USERNAME and password == VALID_PASSWORD:
        # Tạo JWT token
        issued_at = int(time.time())
        expiration_time = issued_at + 300  # Token hết hạn sau 300 giây (5 phút)
        payload = {
            'username': username,
            'iat': issued_at,
            'exp': expiration_time
        }

        token = jwt.encode(payload, SECRET_KEY, algorithm='HS512')

        # Trả về token
        return jsonify({
            "access_token": token,
            "token_type": "Bearer",
            "expires_in": 300
        })
    else:
        return jsonify({"error": "Invalid credentials"}), 401

if __name__ == '__main__':
    app.run(port=5000)

// Đây là Sample Code mang tính chất tham khảo