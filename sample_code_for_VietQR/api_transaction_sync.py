from flask import Flask, request, jsonify
import jwt
from jwt.exceptions import ExpiredSignatureError, InvalidTokenError

app = Flask(__name__)

SECRET_KEY = 'your-256-bit-secret'  # Secret key để kiểm tra JWT

# Model cho request body
class TransactionCallback:
    def __init__(self, data):
        self.transactionid = data.get('transactionid')
        self.transactiontime = data.get('transactiontime')
        self.referencenumber = data.get('referencenumber')
        self.amount = data.get('amount')
        self.content = data.get('content')
        self.bankaccount = data.get('bankaccount')
        self.orderId = data.get('orderId')
        self.sign = data.get('sign')
        self.terminalCode = data.get('terminalCode')
        self.urlLink = data.get('urlLink')
        self.serviceCode = data.get('serviceCode')
        self.subTerminalCode = data.get('subTerminalCode')

# Lớp model cho success response
class SuccessResponse:
    def __init__(self, error, errorReason, toastMessage, object):
        self.error = error
        self.errorReason = errorReason
        self.toastMessage = toastMessage
        self.object = object

# Lớp model cho lỗi response
class ErrorResponse:
    def __init__(self, error, errorReason, toastMessage, object):
        self.error = error
        self.errorReason = errorReason
        self.toastMessage = toastMessage
        self.object = object

# Lớp model cho object trả về trong success response
class TransactionResponseObject:
    def __init__(self, reftransactionid):
        self.reftransactionid = reftransactionid

@app.route('/bank/api/transaction-sync', methods=['POST'])
def transaction_sync():
    auth_header = request.headers.get('Authorization')
    bearer_prefix = 'Bearer '

    if not auth_header or not auth_header.startswith(bearer_prefix):
        return jsonify(ErrorResponse(True, "INVALID_AUTH_HEADER", "Authorization header is missing or invalid", None).__dict__), 401

    token = auth_header[len(bearer_prefix):]

    # Xác thực token
    if not validate_token(token):
        return jsonify(ErrorResponse(True, "INVALID_TOKEN", "Invalid or expired token", None).__dict__), 401

    transaction_callback = TransactionCallback(request.json)

    try:
        # Ví dụ xử lý nghiệp vụ và sinh mã reftransactionid
        ref_transaction_id = "GeneratedRefTransactionId"  # Tạo ID của giao dịch

        # Trả về response 200 OK với thông tin giao dịch
        success_response = SuccessResponse(False, None, "Transaction processed successfully", 
                                           TransactionResponseObject(ref_transaction_id))
        return jsonify(success_response.__dict__), 200

    except Exception as e:
        return jsonify(ErrorResponse(True, "TRANSACTION_FAILED", str(e), None).__dict__), 400

# Phương thức để xác thực token JWT
def validate_token(token):
    try:
        jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return True
    except (ExpiredSignatureError, InvalidTokenError):
        return False

if __name__ == '__main__':
    app.run(debug=True, port=5000)

//sample code mang tính chất tham khảo